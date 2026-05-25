{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  # Determine if host is a physical laptop (fallback to hostname checks if vars.isLaptop is missing)
  isLaptop =
    vars.isLaptop or (
      vars.hostname == "LAPTOP"
      || vars.hostname == "laptop"
      || vars.hostname == "MANX"
      || vars.hostname == "manx"
    );

  # Determine power backend selection: "auto-cpufreq", "tlp", "power-profiles-daemon", or "none"
  # Smart fallback: dynamic auto-cpufreq for laptops, power-profiles-daemon for workstations
  powerBackend = vars.powerBackend or (if isLaptop then "auto-cpufreq" else "power-profiles-daemon");

  # Charge thresholds (standard safe defaults: start charging at 75%, stop at 80%)
  chargeStart = vars.batteryChargeStart or 75;
  chargeStop = vars.batteryChargeStop or 80;
in
{
  # --- AMD P-STATE DRIVER OPTIMIZATION ---
  # Ensures the modern AMD P-state driver is used for maximum efficiency/performance.
  boot.kernelParams = [ "amd_pstate=active" ];

  # --- DYNAMIC POWER MANAGEMENT BACKENDS ---
  # We enforce mutual-exclusion between daemons to avoid kernel tuning conflicts.

  # 1. Standard Power-Profiles-Daemon (Desktop Integrations)
  # Force-disabled if another backend is chosen to prevent conflicts.
  services.power-profiles-daemon.enable = lib.mkForce (powerBackend == "power-profiles-daemon");

  # 2. Traditional TLP Power Management
  services.tlp = lib.mkIf (isLaptop && powerBackend == "tlp") {
    enable = true;
    settings = {
      # CPU Frequency & Scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # Battery Charge Thresholds (Protect battery health)
      START_CHARGE_THRESH_BAT0 = chargeStart;
      STOP_CHARGE_THRESH_BAT0 = chargeStop;

      # Radio/Wireless
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      # Graphics / Disk
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
    };
  };

  # 3. Intelligent CPU Frequency Scaling (auto-cpufreq)
  services.auto-cpufreq.enable = isLaptop && (powerBackend == "auto-cpufreq");
  services.auto-cpufreq.settings = lib.mkIf (isLaptop && powerBackend == "auto-cpufreq") {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # 4. Conflict-Free Battery Charge Threshold Service
  # Runs on laptop boot when TLP is NOT the active backend.
  # Directly interacts with sysfs kernel endpoints to enforce battery boundaries.
  systemd.services.battery-charge-threshold = lib.mkIf (isLaptop && powerBackend != "tlp") {
    description = "Apply hardware-level battery charge thresholds";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "set-battery-thresholds" ''
        # Iterate over all system battery interfaces
        for bat in /sys/class/power_supply/BAT*; do
          if [ -d "$bat" ]; then
            echo "Applying battery health boundaries to $bat..."
            
            # Write start threshold
            if [ -f "$bat/charge_control_start_threshold" ]; then
              echo "${toString chargeStart}" > "$bat/charge_control_start_threshold" || true
            elif [ -f "$bat/charge_start_threshold" ]; then
              echo "${toString chargeStart}" > "$bat/charge_start_threshold" || true
            fi

            # Write end/stop threshold
            if [ -f "$bat/charge_control_end_threshold" ]; then
              echo "${toString chargeStop}" > "$bat/charge_control_end_threshold" || true
            elif [ -f "$bat/charge_stop_threshold" ]; then
              echo "${toString chargeStop}" > "$bat/charge_stop_threshold" || true
            fi
          fi
        done
      '';
    };
  };

  # 5. Global Power Diagnostics & Utilities
  environment.systemPackages = with pkgs; [
    tlp # CLI tools like tlp-stat (useful for checking status)
    powertop # Power consumption diagnostic tool
    acpi # Battery and thermal status
    pciutils # PCI device management (helpful for power debugging)
  ];

  # 6. Automated Power Tuning (Safe Defaults)
  # Only enabled if powerBackend is 'none' to prevent overwriting active backend decisions.
  powerManagement.powertop.enable = isLaptop && (powerBackend == "none");
}
