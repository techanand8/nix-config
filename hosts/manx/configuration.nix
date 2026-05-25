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
    ../../modules/system/amd.nix
    ../../modules/system/postgresql.nix
    ../../modules/system/backups.nix
  ];

  # --- HOST-SPECIFIC HARDWARE KERNEL OPTIMIZATIONS ---
  # These are appended to the common parameters defined in common/boot.nix
  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.fastboot=1"
  ];
}
