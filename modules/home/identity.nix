{ config, vars, ... }:

{
  # Identity and Home Manager Boilerplate
  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = vars.stateVersion;
}
