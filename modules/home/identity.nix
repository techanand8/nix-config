{ config, ... }:

let
  vars = import ../../hosts/msi-modern14c7m/variables.nix;
in
{
  # Identity and Home Manager Boilerplate
  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = vars.stateVersion;
}
