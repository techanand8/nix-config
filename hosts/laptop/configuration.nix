{
  config,
  pkgs,
  lib,
  inputs,
  vars,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
  ];
}
