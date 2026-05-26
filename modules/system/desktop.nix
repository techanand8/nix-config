{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  # A custom declarative package to supply the user avatar (face) to SDDM
  sddm-faces = pkgs.stdenv.mkDerivation {
    name = "sddm-faces";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/sddm/faces
      cp ${./face.icon} $out/share/sddm/faces/${vars.username}.face.icon
      cp ${./face.icon} $out/share/sddm/faces/${vars.username}.face
    '';
  };

  # A highly customized, high-tech Qt6 SDDM theme (Neon Green & Maroon Glow)
  manx-vlsi-theme = pkgs.stdenv.mkDerivation {
    pname = "manx-vlsi-theme";
    version = "3.0";
    src = ./sddm-theme;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/manx-vlsi
      cp -r * $out/share/sddm/themes/manx-vlsi/
    '';
  };
in
{
  # --- GRAPHICS & DISPLAY SERVERS ---
  services.xserver.enable = true;

  # --- DISPLAY MANAGER SYSTEM LAYERS ---
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = lib.mkForce pkgs.kdePackages.sddm;
    # A highly customized, high-tech Qt6 SDDM theme (Neon Green & Maroon Glow)
    theme = "${manx-vlsi-theme}/share/sddm/themes/manx-vlsi";
    extraPackages = [
      manx-vlsi-theme
      sddm-faces
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qt5compat
      pkgs.kdePackages.qtdeclarative
      pkgs.kdePackages.qtwayland
      pkgs.kdePackages.qtvirtualkeyboard
      pkgs.kdePackages.plasma-workspace
      pkgs.kdePackages.plasma-keyboard
    ];
    settings = {
      General = {
        GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell,KWIN_IM_SHOW_ALWAYS=1,QT_IM_MODULE=qtvirtualkeyboard,LC_ALL=en_US.UTF-8,QT_VIRTUALKEYBOARD_NO_SPELLCHECK=1,QSG_RENDER_LOOP=basic";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };

  # Make the custom theme packages visible in the system path so SDDM can find them
  environment.systemPackages = [
    manx-vlsi-theme
    sddm-faces
  ];

  services.desktopManager.plasma6.enable = true;

  # Keyboard Map Setup
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable touchpad/mouse support and gesture mappings (libinput)
  services.libinput.enable = true;

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
      Experimental = true; # Required for battery status & better metadata in some UIs
    };
  };
  services.blueman.enable = true;
  services.upower.enable = true;

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
