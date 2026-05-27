{ pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Required for screen sharing and portals
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" ];
    config.hyprland.default = [
      "hyprland"
      "gtk"
    ];
  };

  # GPU Screen Recorder support for portal backend
  # This provides the necessary setuid wrappers for hardware-accelerated recording
  programs.gpu-screen-recorder.enable = true;

  # Create a wrapper for gpu-screen-recorder so Ambxst's NixOS capability check passes
  security.wrappers.gpu-screen-recorder = {
    owner = "root";
    group = "root";
    source = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder";
  };

  # Required for hyprlock and ambxst to work securely on NixOS
  security.pam.services.hyprlock = { };
  security.pam.services.ambxst = { };

  # Ambxst system-level requirements & functional utilities
  environment.systemPackages = with pkgs; [
    # UI components are handled by Ambxst (Quickshell)
    # We only keep functional backend tools
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    gpu-screen-recorder
    hypridle
    hyprlock
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
