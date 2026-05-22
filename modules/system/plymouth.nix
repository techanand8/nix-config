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



  # Boot timeout - set to 5 seconds (the ideal daily sweet spot for safety and speed)
  boot.loader.timeout = 5;
}
