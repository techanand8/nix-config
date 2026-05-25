{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  isLaptop = vars.hostname == "LAPTOP" || vars.hostname == "laptop";
in
{
  # --- AMD P-STATE DRIVER OPTIMIZATION ---
  # Ensures the modern AMD P-state driver is used for maximum efficiency/performance.
  boot.kernelParams = [ "amd_pstate=active" ];

  # --- DYNAMIC POWER MANAGEMENT STRATEGY ---
  # We use different backends depending on the host type.
  # Laptops need aggressive TLP/auto-cpufreq, while workstations use power-profiles-daemon.

  # 1. Disable conflicting services
  services.power-profiles-daemon.enable = lib.mkForce (!isLaptop);

  # 2. Laptop-Specific Optimizations
  services.tlp = lib.mkIf isLaptop {
    enable = true;
    settings = {
      # CPU Frequency & Scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Battery Charge Thresholds (Protect battery health)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # Radio/Wireless
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      # Graphics / Disk
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
    };
  };

  # 3. Intelligent CPU Frequency Scaling
  services.auto-cpufreq.enable = isLaptop;
  services.auto-cpufreq.settings = lib.mkIf isLaptop {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # 4. Global Power Utilities
  environment.systemPackages = with pkgs; [
    powertop # Power consumption diagnostic tool
    acpi # Battery and thermal status
    pciutils # PCI device management (helpful for power debug)
  ];

  # 5. Automated Power Tuning (Safe Defaults)
  powerManagement.powertop.enable = isLaptop;
}
