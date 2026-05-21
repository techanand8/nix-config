{ config, pkgs, ... }:

let
  vars = import ../../hosts/msi-modern14c7m/variables.nix;
in
{
  # Professional Git Configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = vars.fullName;
        email = vars.email;
      };
    };
  };
}
