{ pkgs, config, ... }:

let
  manx-plymouth-theme = pkgs.stdenv.mkDerivation {
    pname = "manx-plymouth-theme";
    version = "1.0";

    src = ./plymouth;

    installPhase = ''
      mkdir -p $out/share/plymouth/themes/manx
      cp *.png *.jpg manx.plymouth manx.script $out/share/plymouth/themes/manx

      # Fix paths in the plymouth file to point to the nix store
      sed -i "s|/etc/plymouth/themes/manx|$out/share/plymouth/themes/manx|g" $out/share/plymouth/themes/manx/manx.plymouth
    '';
  };
in
{
  boot.plymouth = {
    enable = true;
    theme = "manx";
    themePackages = [ manx-plymouth-theme ];
  };

  # --- FLICKER-FREE & ULTRA-FAST BOOT ---
  # Ensures the screen doesn't blink during the transition from bootloader to OS
  boot.loader.timeout = 5; # Give time to select generations in Limine
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Use systemd in initrd for a cleaner, faster handoff to the main system
  boot.initrd.systemd.enable = true;

  # Optimization: Use fbcon=nodefer to prevent the screen from going dark before Plymouth starts
  boot.kernelParams = [ "fbcon=nodefer" ];
}
