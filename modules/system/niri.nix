{ pkgs, inputs, ... }:

{
  # --- ENABLE NIRI WINDOW MANAGER ---
  programs.niri = {
    enable = true;
  };

  # --- PORTALS & SCREEN SHARING ---
  # Enable GNOME portal for screen sharing in Niri
  xdg.portal = {
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  # --- BACKEND UTILITIES ---
  environment.systemPackages = with pkgs; [
    xwayland-satellite # X11 compatibility bridge for legacy apps (Vivado, Magic)
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default # Install Noctalia package
  ];
}
