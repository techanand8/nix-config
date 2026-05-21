{ config, pkgs, vars, ... }:

{
  # Professional Hardened SSH Configuration (Modern Schema)
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Cleanest approach: only use your custom hardened settings

    # Global Settings for all hosts (*)
    settings = {
      "*" = {
        # Identity Persistence
        AddKeysToAgent = "yes";
        IdentityAgent = "none";
        VerifyHostKeyDNS = "yes";
        PasswordAuthentication = "no";

        # Professional Encryption Standards
        Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com";
        MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com";
        KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];

        # SECURITY HARDENING:
        # Hide the identities of servers you connect to
        HashKnownHosts = "yes";

        # Prevent man-in-the-middle attacks by strictly checking keys
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%h:%p";

        # Enforce strong cryptography (God Mode Encryption)
        ForwardAgent = "no";
      };

      # Specific identity settings for GitHub
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = [ "~/.ssh/id_ed25519" ];
      };
    };
  };

  # Enable the SSH Agent service for the user session
  services.ssh-agent.enable = true;
}
