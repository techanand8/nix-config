{ config, ... }:

{
  # --- Home Manager Activation Scripts (The Nix Way) ---
  # These handle writable folders, theme syncing, and permanent fixes.
  home.activation = {
    setupAmbxst = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $HOME/.config/ambxst/colors $HOME/.config/ghostty $HOME/.local/bin
      $DRY_RUN_CMD chmod -R u+rw $VERBOSE_ARG $HOME/.config/ambxst
      
      # Sync Ghostty colors with current theme
      if [ -f "$HOME/.local/bin/sync_ghostty.sh" ]; then
        $DRY_RUN_CMD bash $HOME/.local/bin/sync_ghostty.sh
      fi

      # Copy presets if they are missing
      PRESET_SRC="/nix/store/$(ls /nix/store | grep ambxst-shell | head -n 1)/assets/presets"
      if [ -d "$PRESET_SRC" ]; then
        $DRY_RUN_CMD cp -rn $VERBOSE_ARG $PRESET_SRC/* $HOME/.config/ambxst/colors/
      fi

      # Permanent Fix: Automatically patch the ambxst core config for gradient syntax
      $DRY_RUN_CMD sed -i 's/inactive_border = "rgb(\([0-9a-fA-F]*\)) rgb(\([0-9a-fA-F]*\))",/inactive_border = { colors = {"rgb(\1)", "rgb(\2)"}, angle = 45 },/' $HOME/.local/share/ambxst/hyprland.lua

      # Set local wallpaper path as default
      if [ -f "$HOME/.cache/ambxst/wallpapers.json" ]; then
        $DRY_RUN_CMD sed -i 's|"wallPath": ".*"|"wallPath": "'$HOME'/Pictures/wallpaper"|' $HOME/.cache/ambxst/wallpapers.json
      fi

      # Automatically trust GitHub's SSH key for automation
      if ! grep -q "github.com" $HOME/.ssh/known_hosts 2>/dev/null; then
        $DRY_RUN_CMD mkdir -p $HOME/.ssh
        $DRY_RUN_CMD ssh-keyscan -t ed25519 github.com >> $HOME/.ssh/known_hosts
      fi
    '';
  };
}
