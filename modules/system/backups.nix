{ pkgs, vars, ... }:

{
  # --- BORGMATIC: Secure, Encrypted, & Deduplicated Off-site Backups ---
  # This module ensures your /persist directory (Engineering data, Design files, Secrets)
  # is backed up automatically.

  services.borgmatic = {
    enable = true;
    settings = {
      location = {
        # The /persist directory contains everything that survives a reboot
        source_directories = [ "/persist" ];

        # --- OFFSITE REPOSITORY CONFIGURATION ---
        # Note: You should initialize your repository first:
        # borgmatic init --encryption repokey-blake2
        repositories = [
          # Example: Local external drive or home NAS
          # "/mnt/backups/manx-workstation.borg"

          # Example: Remote SSH repository (rsync.net, BorgBase, etc.)
          # "user@backupserver.net:manx-workstation.borg"
        ];
      };

      storage = {
        # Use ZSTD for high-fidelity compression of VLSI design data
        compression = "zstd,6";
        encryption_passphrase = "YOUR_MASTER_PASSPHRASE_HERE_OR_USE_SOPS";
      };

      retention = {
        # Keep a professional history of your workstation state
        keep_hourly = 24;
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 6;
      };

      consistency = {
        # Periodically check for bit-rot in your backup design data
        checks = [
          {
            name = "repository";
            frequency = "2 weeks";
          }
        ];
      };
    };
  };

  # Borgmatic system-level utilities
  environment.systemPackages = with pkgs; [
    borgmatic
    borgbackup
  ];
}
