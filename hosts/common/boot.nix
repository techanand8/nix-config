{
  config,
  pkgs,
  lib,
  inputs,
  vars,
  ...
}:

{
  # --- BOOTLOADER (Limine - Graphical Speed Bootloader) ---
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine = {
    enable = true;
    maxGenerations = 20;
    enableEditor = true;
    efiSupport = true;
    efiInstallAsRemovable = true; # High compatibility fallback

    resolution = "auto"; # Auto-detect for best compatibility

    style = {
      wallpapers = [ ../../modules/system/plymouth/red_glow.jpg ];
      wallpaperStyle = "stretched";
      backdrop = "000000";

      interface = {
        resolution = "auto";
        branding = "MANX OS [CACHYOS] | SPEED BOOTLOADER";
        brandingColor = "FF1133"; # Electric Ruby Red
        helpColor = "D0D2D6"; # Cool Silver/Grey
        helpColorBright = "FF1133";
      };

      graphicalTerminal = {
        foreground = "39FF14"; # Neon Green
        brightForeground = "FFFFFF";
        background = "A8080000"; # Translucent Deep Ruby Card
        margin = 100; # Reduced margin to prevent clipping
        marginGradient = 25;
        font = {
          scale = "2x2";
        };
      };
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # --- SYSTEM KERNEL & HARDWARE OPTIMIZATIONS ---
  # Centralized boot configurations for performance, silent boot, and early graphics handoff
  boot.kernelParams = [
    # System Performance & Hardware Tweaks
    "transparent_hugepage=never"
    "btusb.enable_autosuspend=0"

    # Fast & Silent Boot (Optimized for Early KMS)
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "vt.global_cursor_default=0"
  ];

  # Enable the sched-ext framework (CachyOS specialty)
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  systemd.services.scx.restartIfChanged = false;
}
