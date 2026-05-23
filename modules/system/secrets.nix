{
  config,
  pkgs,
  lib,
  inputs,
  vars,
  ...
}:

{
  # Import sops-nix system module dynamically from flake inputs
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # Configure System-level SOPS Vault
  sops = {
    # Default path to the encrypted YAML vault
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # Key file locations to resolve and decrypt secrets
    age = {
      # Relocate the key file path to the early-mounted, persisted directory.
      # Because /home is a separate subvolume not yet mounted when neededForUsers
      # secrets are decrypted, we must use /var/lib/sops-nix/key.txt which mounts early.
      keyFile = "/var/lib/sops-nix/key.txt";
    };

    # --- SECRET MAPPINGS ---
    # These secrets are decrypted from secrets.yaml and placed in /run/secrets/
    secrets = {
      # 1. User Password (Used in users.nix)
      "users/primary-user/password" = {
        neededForUsers = true;
      };

      # 2. GitHub Token (Example for dev environments)
      # "github/token" = {
      #   owner = vars.username;
      # };
    };
  };
}
