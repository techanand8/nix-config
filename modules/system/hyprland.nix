{ pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Required for screen sharing and portals
  services.dbus.enable = true;

  # GPU Screen Recorder support for portal backend
  programs.gpu-screen-recorder.enable = true;

  # Ambxst system-level requirements & functional utilities
  environment.systemPackages = with pkgs; [
    # UI components are handled by Ambxst (Quickshell)
    # We only keep functional backend tools
    awww
    hyprpolkitagent
    kitty
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    nwg-look
    libsForQt5.qt5ct
    kdePackages.qt6ct
    hyprland-qtutils
    brightnessctl
    playerctl
    pavucontrol
    networkmanagerapplet
    libva-utils
    vulkan-tools
  ];

  # Security / Keyring for apps
  services.gnome.gnome-keyring.enable = true;
}
