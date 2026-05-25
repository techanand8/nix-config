{
  pkgs,
  lib,
  vars,
  ...
}:

{
  # Enable AMD GPU Drivers
  services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" ];

  # Early KMS support for smoother boot and SDDM transition
  boot.initrd.kernelModules = [ "amdgpu" ];

  # ROCm for AI/ML acceleration
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkDefault true;
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

  # --- LACT: Professional AMD GPU Dashboard & Control ---
  # Allows real-time monitoring of clocks, thermals, and power states.
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  environment.systemPackages = [ pkgs.lact ];

  # Ensure user has permissions to control the GPU via LACT
  users.users."${vars.username}".extraGroups = [
    "video"
    "render"
  ];
}
