{ pkgs, config, ... }:

let
  mayank-plymouth-theme = pkgs.stdenv.mkDerivation {
    pname = "mayank-plymouth-theme";
    version = "1.0";

    src = ./plymouth;

    installPhase = ''
      mkdir -p $out/share/plymouth/themes/mayank
      cp *.png *.jpg mayank.plymouth mayank.script $out/share/plymouth/themes/mayank
      
      # Fix paths in the plymouth file to point to the nix store
      sed -i "s|/etc/plymouth/themes/mayank|$out/share/plymouth/themes/mayank|g" $out/share/plymouth/themes/mayank/mayank.plymouth
    '';
  };
in
{
  boot.plymouth = {
    enable = true;
    theme = "mayank";
    themePackages = [ mayank-plymouth-theme ];
  };

  # --- SILENT BOOT CONFIGURATION ---
  # These settings ensure a clean, flicker-free boot experience
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Enable systemd in initrd for faster and smoother transition
  boot.initrd.systemd.enable = true;

  # Ensure amdgpu is loaded as early as possible for early KMS
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.initrd.availableKernelModules = [ "amdgpu" "xhci_pci" "nvme" "usb_storage" "sd_mod" ];

  boot.kernelParams = [
    "quiet" # Master silence flag
    "splash" # Required for Plymouth
    "rd.systemd.show_status=false" # Hides systemd status messages in initrd
    "rd.udev.log_level=0" # Mutes udev in initrd completely
    "udev.log_priority=0" # Mutes udev in main system completely
    "vt.global_cursor_default=0" # Hides the blinking underscore cursor
    "fbcon=nodefer" # Smooth handover to graphics
    "amdgpu.fastboot=1" # Skips unnecessary mode sets for AMD
    "boot.shell_on_fail" # Keep this so you can debug if it ever fails
  ];

  # Boot timeout - optimized for speed on modern SSD while remaining accessible
  boot.loader.timeout = 2;
}
