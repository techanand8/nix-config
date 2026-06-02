{
  config,
  pkgs,
  vars,
  ...
}:

{
  # --- 1PASSWORD SYSTEM INTEGRATION ---
  # Enables the 1Password CLI and system-level daemon integration.
  programs._1password.enable = true;

  # Enables the 1Password GUI application with professional features.
  programs._1password-gui = {
    enable = true;
    # Allows 1Password to use system-level authentication (Fingerprint/Polkit)
    # and enables the 1Password SSH Agent integration.
    polkitPolicyOwners = [ "${vars.username}" ];
  };

  # Ensure the user is in the 'onepassword' group for CLI/GUI communication if needed
  # (The module usually handles this, but we'll be explicit for reliability)
  users.users."${vars.username}".extraGroups = [ "onepassword" ];
}
