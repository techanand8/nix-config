{ pkgs, ... }:

let
  xppen-v4 = import ./xppen-driver.nix { inherit pkgs; };

  pentablet-shortcut = pkgs.makeDesktopItem {
    name = "pentablet";
    desktopName = "XP-Pen Pentablet";
    exec = "pentablet";
    icon = "input-tablet";
    comment = "Driver for Deco Mini 7 V2";
    categories = [ "Settings" "HardwareSettings" ];
    terminal = false;
  };
in
{
  # Hardware Detection Fix
  system.activationScripts.xppen-patch = {
    text = ''
      mkdir -p /usr/lib/pentablet
      ln -sfn ${xppen-v4}/lib/pentablet/conf /usr/lib/pentablet/conf
      ln -sfn ${xppen-v4}/lib/pentablet/resource /usr/lib/pentablet/resource
    '';
  };

  environment.systemPackages = [
    xppen-v4
    pentablet-shortcut
  ];

  # Load udev rules
  services.udev.packages = [ xppen-v4 ];

  # Autostart Service
  systemd.user.services.pentablet-autostart = {
    description = "Launch XP-Pen Driver on Login";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'export QT_QPA_PLATFORM=xcb; ${xppen-v4}/bin/pentablet'";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
