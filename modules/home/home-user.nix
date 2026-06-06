{
  config,
  pkgs,
  vars,
  ...
}:

{
  # =========================================================================
  # MAIN USER HUB (home-user.nix)
  # This file connects all modular components of the system.
  # =========================================================================

  imports = [
    ./identity.nix # Identity & Identity Boilerplate
    ./firefox.nix # Declarative Firefox & VLSI Semiconductor Dashboard
    ./user-packages.nix # General User Apps
    ./fastfetch.nix # Premium Fastfetch System Dashboard
    ./vlsi.nix # Engineering & VLSI Tools
    ./shell.nix # Zsh, Zoxide, Aliases
    ./git.nix # Git Settings
    ./hyprland.nix # Pure Lua Desktop logic
    ./niri.nix # Niri Desktop configuration
    ./starship.nix # Terminal Prompt logic
    ./yazi.nix # File Manager logic
    ./nixvim.nix # Neovim IDE logic
    ./apps.nix # Utility/Fun scripts
    ./development.nix # Dev environment basics
    ./activation.nix # Theme syncing & Permission fixes
    ./ssh.nix # SSH Identity & Agent
  ];
}
