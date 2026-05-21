{ config, pkgs, inputs, vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/amd.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/scripts.nix
    ../../modules/system/xppen.nix
    ../../modules/system/fonts.nix
    ../../modules/system/vivado.nix
    ../../modules/system/plymouth.nix
  ];

  # --- SYSTEM OPTIMIZATIONS ---
  services.fstrim.enable = true;
  zramSwap.enable = true; # High-speed compressed RAM swap
  services.power-profiles-daemon.enable = true; # Best power management for Plasma 6
  services.irqbalance.enable = true; # Distribute hardware interrupts across cores
  services.fwupd.enable = true; # Enable firmware updates (BIOS, SSD, etc.)

  # Btrfs Maintenance (Prevent bit-rot)
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "monthly";

  # Prevent log files from growing indefinitely
  services.journald.extraConfig = "SystemMaxUse=100M";

  # Use RAM for /tmp to speed up rebuilds and save SSD
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%"; # Use up to 50% of RAM

  # --- BOOTLOADER (Limine - The Pro Choice) ---
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10;
    enableEditor = false;
    efiSupport = true;
    # Ensures it works even on laptops with "forgetful" UEFI entries
    efiInstallAsRemovable = true;

    # Framebuffer resolution for early boot/Linux GOP graphical handoff (ensures high-res Plymouth)
    resolution = "1920x1080";

    style = {
      # Adding your Anime image as the background!
      wallpapers = [ ../../modules/system/plymouth/boot_wallpaper.jpg ];
      wallpaperStyle = "stretched";
      backdrop = "000000"; # Black backdrop for centered/tiled cases

      interface = {
        resolution = "1920x1080"; # High-definition graphical mode for the menu interface
        branding = "MAYANK NIXOS";
        brandingColor = "39FF14"; # Neon green accent
        helpColor = "39FF14"; # Neon green help text
      };

      graphicalTerminal = {
        foreground = "39FF14"; # Neon green terminal text
        background = "80000000"; # Semi-transparent black terminal backdrop (80% opacity)
      };
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;

  # LUKS Encryption (DO NOT CHANGE)
  boot.initrd.luks.devices."luks-6a6e61c8-3a4f-4223-9a31-47a2c6368b03".device = "/dev/disk/by-uuid/6a6e61c8-3a4f-4223-9a31-47a2c6368b03";

  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;

  time.timeZone = vars.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = vars.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = vars.locale;
    LC_IDENTIFICATION = vars.locale;
    LC_MEASUREMENT = vars.locale;
    LC_MONETARY = vars.locale;
    LC_NAME = vars.locale;
    LC_NUMERIC = vars.locale;
    LC_PAPER = vars.locale;
    LC_TELEPHONE = vars.locale;
    LC_TIME = vars.locale;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- VIRTUALIZATION & CONTAINERS ---
  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.host.extraConfig = ''
    # Advanced Keymap Support
    xkeymap.useLocalxkb = "TRUE"
    xkeymap.nokeycodeMap = "TRUE"

    # USB Passthrough (HID/Mice/Keyboards)
    usb.generic.allowHID = "TRUE"
    usb.generic.allowLastHID = "TRUE"
  '';

  # Container Support (for Distrobox)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Firmware & Bluetooth Support
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      AutoEnable = true;
    };
  };
  services.blueman.enable = true;

  # Flatpak & KDE Connect
  services.flatpak.enable = true;
  programs.kdeconnect.enable = true;

  # Firewall Security
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ]; # LocalSend file transfer and discovery
  };

  # PAM Security (Auto-unlock Keyring)
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Fix nix-config permissions permanently (Root Level)
  system.activationScripts.fix-nix-config-perms = {
    text = ''
      chown -R ${vars.username}:users /home/${vars.username}/nix-config
      chmod -R u+rw /home/${vars.username}/nix-config
    '';
    deps = [ ];
  };

  # Performance tweak for VMware and VLSI workloads
  # amd_pstate=active enables hardware-controlled frequency scaling for Ryzen
  boot.kernelParams = [
    "transparent_hugepage=never"
    "btusb.enable_autosuspend=0"
    "amd_pstate=active"
  ];

  # Enable the sched-ext framework (CachyOS specialty)
  # scx_lavd is excellent for interactive smoothness on laptops
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  # Users
  users.users."${vars.username}" = {
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    shell = pkgs.zsh;
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  # Nix Settings & Cachix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;

    # Allows root, users in the 'wheel' group, and your specific user to specify custom binary caches/substituters
    trusted-users = [ "root" "@wheel" "${vars.username}" ];

    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Global Packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    gemini-cli-bin
    vmware-workstation
    distrobox
    xhost
    usbutils
    ripgrep
    imagemagick

    # --- SECURE VPN & CORPORATE NETWORK CONNECTIVITY ---
    openconnect # Cisco AnyConnect, GlobalProtect, Fortinet CLI client
    openfortivpn # Fortinet SSL VPN client
    openvpn # OpenVPN protocol client
    wireguard-tools # Modern WireGuard VPN tools
    networkmanager-openvpn # OpenVPN NetworkManager GUI integration
    networkmanager-openconnect # Cisco/GlobalProtect NetworkManager GUI integration
  ];

  programs.firefox.enable = true;
  # programs.command-not-found.enable = true;
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

  system.stateVersion = vars.stateVersion;
}
