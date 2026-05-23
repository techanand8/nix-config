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
      # Use the existing user-owned age key that is already present on this machine.
      # This keeps SOPS decryption working immediately after rebuild.
      keyFile = "/home/${vars.username}/.config/sops/age/keys.txt";
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
