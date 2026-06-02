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
  # Keep enough time in Limine to select generations manually.
  boot.loader.timeout = 5;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Use systemd in initrd for a cleaner, faster handoff to the main system.
  boot.initrd.systemd.enable = true;

  # Plymouth can pause for several seconds while waiting for a DRM device,
  # especially with systemd-initrd on some AMD systems. Let it use the early
  # simpledrm framebuffer immediately, then hand off cleanly once amdgpu is ready.
  boot.kernelParams = [
    "loglevel=3"
    "systemd.show_status=auto"
    "fbcon=nodefer"
    "plymouth.use-simpledrm"
  ];
}
