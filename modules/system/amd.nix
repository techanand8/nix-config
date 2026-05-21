{ pkgs, ... }:

{
  # Enable AMD GPU Drivers
  services.xserver.videoDrivers = [ "amdgpu" ];

  # ROCm for AI/ML acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva-utils
      vdpauinfo
      libvdpau-va-gl
    ];
  };

  # OpenCL support
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
}
