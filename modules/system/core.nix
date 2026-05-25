{
  config,
  pkgs,
  lib,
  inputs,
  vars,
  ...
}:

{
  # --- SYSTEM PERFORMANCE OPTIMIZATIONS ---
  services.fstrim.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50; # Use up to 50% of RAM as compressed swap
  };
  services.power-profiles-daemon.enable = true; # Optimized power management for workstations
  services.irqbalance.enable = true; # Distribute hardware interrupts across cores
  services.fwupd.enable = true; # Enable firmware updates (BIOS, SSD, etc.)

  # Btrfs Maintenance (Prevent bit-rot)
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "monthly";

  # Prevent log files from growing indefinitely
  services.journald.extraConfig = "SystemMaxUse=100M";

  # Use RAM for /tmp (fast)
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%"; # Up to 50% of RAM for /tmp
  boot.tmp.cleanOnBoot = true;

  # Force Nix to use the SSD for builds so it doesn't crash your RAM
  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

  # --- NETWORKING BASE ---
  networking.networkmanager.enable = true;

  # --- DECLARATIVE PERMISSIONS ---
  # Use systemd-tmpfiles to manage permissions declaratively.
  # 'Z' recursively sets ownership and permissions on the directory.
  systemd.tmpfiles.rules = [
    "Z /home/${vars.username}/nix-config 0755 ${vars.username} users - -"
  ];

  # --- DEEP NIX STORE & FLAKE CONFIGURATIONS ---
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;

    # Authorize root, users in the 'wheel' group, and the main user account to configure binary cache substituters.
    trusted-users = [
      "root"
      "@wheel"
      "${vars.username}"
    ];

    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://attic.xuyh0120.win/lantian"
    ]
    ++ (lib.optionals
      (vars ? cachixName && vars.cachixName != "" && vars.cachixName != "your-cachix-subdomain")
      [
        "https://${vars.cachixName}.cachix.org"
      ]
    );

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ]
    ++ (lib.optionals
      (
        vars ? cachixPublicKey
        && vars.cachixPublicKey != ""
        && vars.cachixName != "your-cachix-subdomain"
        && vars.cachixPublicKey != "your-cachix-subdomain.cachix.org-1:your-public-key"
      )
      [
        "${vars.cachixPublicKey}"
      ]
    );
  };

  # --- DECLARATIVE CONSISTENCY ---
  # Pins all flake inputs in the registry and NIX_PATH, ensuring legacy tools
  # (nix-shell, nix-env) use the exact same revisions as your flake.lock.
  nix.registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  nix.channel.enable = false; # Disable channels as we are fully declarative with Flakes

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- CORE UTILITY & NETWORKING SOFTWARE ---
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    gemini-cli-bin
    distrobox
    xhost
    usbutils
    ripgrep
    imagemagick

    # --- SYSTEM MANAGEMENT HELPERS ---
    nh # Better UI for rebuilds
    nix-output-monitor # Beautiful progress bars
    nvd # Show exactly what packages changed after rebuild
    cachix # Binary cache management tool
    cryptsetup # LUKS management tools

    # --- SECURE DECRYPT / ENCRYPT UTILS (Secrets Management) ---
    sops # Encryption/Decryption tool
    age # File encryption tool (standard for sops-nix keys)

    # --- SECURE VPN & CORPORATE NETWORK CONNECTIVITY ---
    openconnect # Cisco AnyConnect, GlobalProtect, Fortinet CLI client
    openfortivpn # Fortinet SSL VPN client
    openvpn # OpenVPN protocol client
    wireguard-tools # Modern WireGuard VPN tools
    networkmanager-openvpn # OpenVPN NetworkManager GUI integration
    networkmanager-openconnect # Cisco/GlobalProtect NetworkManager GUI integration
  ];

  programs.firefox.enable = true;
  programs.ambxst.enable = true;
  programs.zsh.enable = true;

  # --- FHS, NIX-LD, & ENVIRONMENT SCRIPTS SUPPORT ---
  # Enable envfs to dynamically resolve shebangs like #!/bin/bash, #!/usr/bin/env, etc.
  services.envfs.enable = true;

  # Enable nix-ld to run unpatched dynamic binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Core/System
      stdenv.cc.cc.lib
      zlib
      zstd
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      libuuid
      libusb1

      # Graphics & Windowing
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxcb
      libice
      libsm
      libxshmfence
      libxkbfile
      libGL
      libva
      mesa
      libxkbcommon
      libdrm

      # General Desktop / Audio / Fonts
      glib
      gtk3
      pango
      cairo
      atk
      gdk-pixbuf
      fontconfig
      freetype
      dbus
      alsa-lib
      expat
      pipewire
      nspr
      nss
    ];
  };

  # Rename the distribution system-wide (replaces "NixOS" in bootloader entry titles)
  system.nixos.distroName = "MANX OS";

  # --- BTRFS SNAPSHOTS (TIME MACHINE) ---
  # Automated snapshots for the home subvolumes.
  # Root is excluded because it is stateless and wiped on every boot.
  services.snapper = {
    configs = {
      home = {
        SUBVOLUME = "/home";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        LIMIT_HOURLY = "10";
        LIMIT_DAILY = "7";
        LIMIT_WEEKLY = "3";
        LIMIT_MONTHLY = "0";
        LIMIT_YEARLY = "0";
      };
    };
  };
}
