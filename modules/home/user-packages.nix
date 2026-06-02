{ config, pkgs, ... }:

{
  # --- Shared User Packages (Daily Use, Multimedia, Creative) ---
  home.packages = with pkgs; [
    # --- Browsers & Communication ---
    microsoft-edge
    brave
    google-chrome
    tor-browser
    protonvpn-gui
    telegram-desktop
    discord
    localsend

    # --- Multimedia & Creative ---
    vlc
    mpv
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

    # --- ELITE DEVELOPER UTILS ---
    xdotool # Command-line X11 automation tool
    wlrctl # Wayland-native automation tool
    nix-index # File-to-package indexer
    comma # Run any nix command without installing (usage: , <cmd>)
    git-lfs # Git Large File Storage for hosting huge files
    python3Packages.huggingface-hub # Hugging Face CLI & SDK for private dataset backups
  ];
}
