{
  pkgs,
  vars,
  ...
}:

let
  xppen-v4 = import ./xppen-driver.nix { inherit pkgs vars; };

  pentablet-shortcut = pkgs.makeDesktopItem {
    name = "pentablet";
    desktopName = "XP-Pen Pentablet";
    exec = "env QT_QPA_PLATFORM=xcb pentablet";
    icon = "pentablet";
    comment = "Driver for Deco Mini 7 V2";
    categories = [
      "Settings"
      "HardwareSettings"
    ];
    terminal = false;
  };
in
{
  # Hardware Detection Fix - Use tmpfiles to create legacy paths for proprietary drivers
  # This replaces the activation script that tried to write to read-only /usr/lib
  systemd.tmpfiles.rules = [
    "L+ /usr/lib/pentablet/conf - - - - ${xppen-v4}/lib/pentablet/conf"
    "L+ /usr/lib/pentablet/resource - - - - ${xppen-v4}/lib/pentablet/resource"
  ];

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
