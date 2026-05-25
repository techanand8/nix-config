{ config, lib, pkgs, vars, ... }:

{
  # --- ATTIC BINARY CACHE SERVER ---
  # This sets up a local private cache on the MANX workstation.
  services.atticd = {
    enable = true;

    # Database & Storage
    # We use SQLite for simplicity and store it in /persist to survive reboots.
    database.url = "sqlite:///persist/var/lib/atticd/server.db?mode=rwc";

    settings = {
      listen = "[::]:8080";
      
      # Storage Backend
      # This is where the actual .nar files are stored.
      storage = {
        type = "local";
        path = "/persist/var/lib/atticd/storage";
      };

      # Security: Token Generation
      # You'll need to generate a secret key once after the first boot.
      # We point it to a file that should be kept secret.
      # Note: For now, we use a placeholder; you'll need to generate this.
      jwt = {
        # This should point to a secret file managed by SOPS-nix in a real setup.
        # For simplicity, we'll use a path that we can create manually or via SOPS.
        secret_key_file = "/persist/var/lib/atticd/jwt-secret";
      };

      # --- SPACE MANAGEMENT (Garbage Collection) ---
      # This keeps your disk from filling up.
      garbage-collection = {
        interval = "12 hours";
        # Keep only the last 30GB of builds.
        max-size = 30 * 1024 * 1024 * 1024; # 30 GB in bytes
      };
    };
  };

  # Ensure the directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /persist/var/lib/atticd 0700 atticd atticd -"
    "d /persist/var/lib/atticd/storage 0700 atticd atticd -"
  ];

  # Allow the Attic port through the firewall so your LAPTOP can connect
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
