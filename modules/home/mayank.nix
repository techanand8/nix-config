{ config, pkgs, vars, ... }:

{
  # =========================================================================
  # MAIN USER HUB (mayank.nix)
  # This file connects all modular components of the system.
  # =========================================================================

  imports = [
    ./identity.nix # Identity & Identity Boilerplate
    ./user-packages.nix # General User Apps
    ./fastfetch.nix # Premium Fastfetch System Dashboard
    ./vlsi.nix # Engineering & VLSI Tools
    ./shell.nix # Zsh, Zoxide, Aliases
    ./git.nix # Git Settings
    ./hyprland.nix # Pure Lua Desktop logic
    ./starship.nix # Terminal Prompt logic
    ./yazi.nix # File Manager logic
    ./nixvim.nix # Neovim IDE logic
    ./apps.nix # Utility/Fun scripts
    ./development.nix # Dev environment basics
    ./activation.nix # Theme syncing & Permission fixes
    ./ssh.nix # SSH Identity & Agent
  ];
}
