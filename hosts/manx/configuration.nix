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
    ./hardware-configuration.nix
    ../../modules/system/core.nix
    ../../modules/system/desktop.nix
    ../../modules/system/virtualization.nix
    ../../modules/system/users.nix
    ../../modules/system/secrets.nix
    ../../modules/system/amd.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/scripts.nix
    ../../modules/system/xppen.nix
    ../../modules/system/fonts.nix
    ../../modules/system/vivado.nix
    ../../modules/system/plymouth.nix
    ../../modules/system/apps.nix
  ];

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

  # --- BOOTLOADER (Limine - Graphical Speed Bootloader) ---
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10;
    enableEditor = false;
    efiSupport = true;
    efiInstallAsRemovable = true; # High compatibility fallback

    resolution = "1920x1080"; # Graphics GOP graphical handoff

    style = {
      wallpapers = [ ../../modules/system/plymouth/red_glow.jpg ];
      wallpaperStyle = "stretched";
      backdrop = "000000";

      interface = {
        resolution = "1920x1080";
        branding = "MANX OS [CACHYOS] | SPEED BOOTLOADER";
        brandingColor = "FF1133"; # Electric Ruby Red
        helpColor = "D0D2D6"; # Cool Silver/Grey
        helpColorBright = "FF1133";
      };

      graphicalTerminal = {
        foreground = "39FF14"; # Neon Green
        brightForeground = "FFFFFF";
        background = "A8080000"; # Translucent Deep Ruby Card
        margin = 180;
        marginGradient = 25;
        font = {
          scale = "2x2";
        };
      };
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # --- SYSTEM KERNEL & HARDWARE OPTIMIZATIONS ---
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
  hardware.enableRedistributableFirmware = true;

  # Centralized boot configurations for performance, silent boot, and early graphics handoff
  boot.kernelParams = [
    # System Performance & Hardware Tweaks
    "transparent_hugepage=never"
    "btusb.enable_autosuspend=0"
    "amd_pstate=active"

    # Silent Boot & Plymouth Handover
    "quiet" # Master silence flag
    "splash" # Required for Plymouth boot animation
    "plymouth.use-simpledrm" # Force Plymouth to use early EFI/SimpleDRM framebuffer (avoids the 8s delay waiting for GPU driver)
    "rd.systemd.show_status=false" # Hides systemd status messages in initrd
    "rd.udev.log_level=0" # Mutes udev in initrd completely
    "udev.log_priority=0" # Mutes udev in main system completely
    "vt.global_cursor_default=0" # Hides the blinking underscore cursor
    "fbcon=nodefer" # Smooth handover to graphics
    "amdgpu.fastboot=1" # Skips unnecessary mode sets for AMD
    "boot.shell_on_fail" # Retain a shell prompt on boot failure for diagnostics
  ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 1048576;
  };

  # Enable the sched-ext framework (CachyOS specialty)
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  # --- HOST-SPECIFIC PACKAGES ---
  environment.systemPackages = [
    pkgs.vmware-workstation
  ];

  # --- STATE COMPATIBILITY VERSION ---
  system.stateVersion = vars.stateVersion;
}
