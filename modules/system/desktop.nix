{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

{
  # --- GRAPHICS & DISPLAY SERVERS ---
  services.xserver.enable = true;

  # --- KDE PLASMA 6 SYSTEM LAYERS ---
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Keyboard Map Setup
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing Integration (CUPS)
  services.printing.enable = true;

  # --- MODERN SOUND PROTOCOLS (Pipewire & RTKit) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- WIRELESS INTERFACES (Bluetooth & Blueman) ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      AutoEnable = true;
    };
  };
  services.blueman.enable = true;

  # --- DESKTOP INTERCONNECTS (Flatpak & KDE Connect) ---
  services.flatpak.enable = true;
  programs.kdeconnect.enable = true;

  # --- LOCAL FIREWALL INTEGRATION ---
  # Allows localized secure discovery/communication (e.g. LocalSend protocol)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
