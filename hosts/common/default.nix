{
  config,
  pkgs,
  lib,
  inputs,
  vars,
  ...
}:

{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./boot.nix
    ../../modules/system/core.nix
    ../../modules/system/desktop.nix
    ../../modules/system/virtualization.nix
    ../../modules/system/users.nix
    ../../modules/system/secrets.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/scripts.nix
    ../../modules/system/xppen.nix
    ../../modules/system/fonts.nix
    ../../modules/system/vivado.nix
    ../../modules/system/plymouth.nix
    ../../modules/system/apps.nix
    ../../modules/system/vpn.nix
    ../../modules/system/ai.nix
    ../../modules/system/power.nix
    ../../modules/system/thunar.nix
  ]
  ++ (lib.optionals (vars ? enableImpermanence && vars.enableImpermanence) [
    ../../modules/system/stateless.nix
  ]);

  # --- HOST IDENTIFICATION ---
  networking.hostName = vars.hostname;
  time.timeZone = vars.timezone;

  # --- LOCALIZATION & INTERNATIONALIZATION ---
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

  # --- SYSTEM KERNEL & HARDWARE OPTIMIZATIONS ---
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
  hardware.enableRedistributableFirmware = true;

  # High-performance kernel tweaks for VLSI (massive compiles/simulations) & Deep Learning
  boot.kernel.sysctl = {
    "vm.max_map_count" = 1048576; # PyTorch / Elasticsearch database speedup
    "vm.swappiness" = 10; # Prefer RAM over swap, reduces latency for heavy workloads
    "vm.vfs_cache_pressure" = 50; # Keep file/directory metadata cached longer (speeds up compiles)
    "fs.file-max" = 2097152; # Max number of open files system-wide
  };

  # Maximize system limits for engineering tools (Vivado/OpenLane) and ML frameworks (PyTorch DataLoader)
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "-";
      item = "stack";
      value = "unlimited";
    }
  ];

  # --- HOST-SPECIFIC PACKAGES ---
  environment.systemPackages = [
    pkgs.vmware-workstation
  ];

  # --- STATE COMPATIBILITY VERSION ---
  system.stateVersion = vars.stateVersion;
}
