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
    inputs.disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disko.nix
    ../common/default.nix
    ../../modules/system/amd.nix
    ../../modules/system/postgresql.nix
    ../../modules/system/backups.nix
  ];

  # --- DISKO PERSISTENCE OVERRIDES ---
  fileSystems."/home".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  # --- HOST-SPECIFIC HARDWARE KERNEL OPTIMIZATIONS ---
  # These are appended to the common parameters defined in common/boot.nix
  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.fastboot=1"
    "amdgpu.gpu_recovery=1" # Allow driver to restart if it hangs
    "amdgpu.sg_display=0" # Fix blinking/flickering on some AMD APUs
    "amdgpu.dcdebugmask=0x10" # Advanced display stability for Vega/Barcelo
    "iommu=pt" # Better IOMMU performance/stability for GPU
  ];
}
