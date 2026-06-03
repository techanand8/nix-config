{
  config,
  pkgs,
  inputs,
  ...
}:

let
  yt-x = pkgs.stdenv.mkDerivation rec {
    pname = "yt-x";
    version = "latest";

    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Benexl/yt-x/refs/heads/master/yt-x";
      sha256 = "0zpsjgyhc5pgz8jr2vp2ci3yg1vmnbcq27k602lgjra39hr2dg9c";
    };

    dontUnpack = true;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/yt-x
      chmod +x $out/bin/yt-x
      wrapProgram $out/bin/yt-x \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.yt-dlp
            pkgs.fzf
            pkgs.jq
            pkgs.curl
            pkgs.mpv
            pkgs.chafa
            pkgs.ffmpeg
          ]
        }
    '';
  };
in
{
  # --- Shared User Packages (Daily Use, Multimedia, Creative) ---
  home.packages = with pkgs; [
    # --- Browsers & Communication ---
    microsoft-edge
    brave
    google-chrome
    tor-browser
    proton-vpn
    telegram-desktop
    discord
    localsend

    # --- Multimedia & Creative ---
    vlc
    mpv
    yt-dlp # Ultimate video/audio downloader
    ani-cli # CLI Anime streaming tool
    yt-x # Interactive terminal YouTube browser & player
    loupe # Premium modern image viewer (GNOME)
    snapshot # Best modern camera/webcam application
    kdePackages.kdenlive
    kdePackages.dragon

    # --- Software Stores (GUI) ---
    gnome-software
    kdePackages.discover

    # --- Professional Productivity & Documentation ---
    onlyoffice-desktopeditors
    libreoffice-fresh
    glow # Premium markdown renderer for the terminal
    xournalpp
    texlive.combined.scheme-full

    # --- Editors & Terminal ---
    vscode-fhs
    antigravity-fhs
    zed-editor
    yazi
    fastfetch
    htop
    btop
    eza
    bat
    fzf
    zsh-fzf-tab
    vim-full # Includes gvim
    tree
    lsd
    tmux
    kitty
    alacritty
    ghostty
    xterm
    neovide

    # --- CARTOON SHELL (QUICKSHELL PANEL) ---
    quickshell # Desktop components framework (QML)
    qt6.qt5compat # Required for blur and graphical effects
    qt6.qtmultimedia # Required for volume / lockscreen media visualizers
    qt6.qtshadertools # Required for modern QML shader effects
    qt6.qtimageformats # Support for additional image formats in QML
    kdePackages.kirigami # Required for Breeze-styled elements (tooltips, controls)
    kdePackages.qqc2-desktop-style # Desktop styling for QuickShell components
    cava # Sound visualizer backend
    ffmpeg # Required by Cartoon Shell for background wallpaper processing
    playerctl # Media control CLI (used by Music Panel)
    wl-clipboard # Wayland clipboard management
    jq # JSON processing for weather and API calls
    procps # System monitoring (top, free)
    iproute2 # Networking info (ip command)

    matugen # Required by Cartoon Shell for Material You dynamic color palette generation

    # --- ELITE DEVELOPER UTILS ---
    xdotool # Command-line X11 automation tool
    wlrctl # Wayland-native automation tool
    nix-index # File-to-package indexer
    comma # Run any nix command without installing (usage: , <cmd>)
    git-lfs # Git Large File Storage for hosting huge files
    python3Packages.huggingface-hub # Hugging Face CLI & SDK for private dataset backups
  ];
}
