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
      # Custom age key file location
      keyFile = "/home/${vars.username}/.config/sops/age/keys.txt";

      # Pro-Tip: Automatically derive age decryption keys from existing SSH host keys.
      # This allows the machine's hardware key to act as the password-less decryptor at boot!
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    # PLACEHOLDER: Define actual secrets mapping here when ready.
    # Examples:
    # secrets.github_token = {};
    # secrets."users/mayank-password" = {
    #   neededForUsers = true;
    # };
  };
}
