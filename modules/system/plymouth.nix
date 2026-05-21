{ pkgs, config, ... }:

let
  mayank-plymouth-theme = pkgs.stdenv.mkDerivation {
    pname = "mayank-plymouth-theme";
    version = "1.0";

    src = ./plymouth;

    installPhase = ''
      mkdir -p $out/share/plymouth/themes/mayank
      cp *.png mayank.plymouth mayank.script $out/share/plymouth/themes/mayank
      
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

  # Ensure amdgpu is loaded early for Plymouth
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "vt.global_cursor_default=0"
    "fbcon=nodefer" # Prevents framebuffer console from deferred takeover
  ];

  # Fast boot by reducing timeout
  boot.loader.timeout = 0;
}
