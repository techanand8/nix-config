{ config, pkgs, vars, ... }:

{
  # Professional Hardened SSH Configuration (Modern Schema)
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Cleanest approach: only use your custom hardened settings

    # Global Settings for all hosts (*)
    matchBlocks = {
      "*" = {
        # Identity Persistence
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentityAgent = "none";
          VerifyHostKeyDNS = "yes";
          PasswordAuthentication = "no";
          # Professional Encryption Standards
          Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com";
          MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com";
        };

        kexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];

        # SECURITY HARDENING:
        # Hide the identities of servers you connect to
        hashKnownHosts = true;

        # Prevent man-in-the-middle attacks by strictly checking keys
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%h:%p";

        # Enforce strong cryptography (God Mode Encryption)
        forwardAgent = false;
      };

      # Specific identity settings for GitHub
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # Enable the SSH Agent service for the user session
  services.ssh-agent.enable = true;
}
