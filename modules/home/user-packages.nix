{ config, pkgs, ... }:

{
  # --- Shared User Packages (Daily Use, Multimedia, Creative) ---
  home.packages = with pkgs; [
    # --- Browsers & Communication ---
    firefox
    microsoft-edge
    brave
    google-chrome
    telegram-desktop
    discord
    localsend

    # --- Multimedia & Creative ---
    vlc
    mpv
    kdePackages.kdenlive
    kdePackages.dragon

    # --- Software Stores (GUI) ---
    gnome-software
    kdePackages.discover

    # --- Productivity & Education ---
    libreoffice-fresh
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
    nix-index # File-to-package indexer
    comma # Run any nix command without installing (usage: , <cmd>)
  ];
}
