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
    # Falls back to the example file if the private vault is not staged/tracked (e.g. in pure CI checks)
    defaultSopsFile =
      let
        secretsFile = ../../secrets/secrets.yaml;
        exampleFile = ../../secrets/secrets.yaml.example;
      in
      if builtins.pathExists secretsFile then secretsFile else exampleFile;
    defaultSopsFormat = "yaml";

    # Key file locations to resolve and decrypt secrets
    age = {
      # Relocate the key file path to the physical, early-mounted /persist subvolume.
      # Since impermanence bind-mounts run too late for neededForUsers password decryption,
      # pointing directly to the /persist subvolume (which has neededForBoot = true) is required.
      keyFile = "/persist/var/lib/sops-nix/key.txt";
    };

    # --- SECRET MAPPINGS ---
    # These secrets are decrypted from secrets.yaml and placed in /run/secrets/
    secrets = {
      # 1. Root Password (Used in users.nix)
      "users/root/password" = {
        neededForUsers = true;
      };

      # 2. User Password (Used in users.nix)
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
