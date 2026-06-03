#!/usr/bin/env bash

# =========================================================================
# GHOSTTY & SYSTEM THEME SYNC ENGINE
# Auto-synced with Ambxst System Colors
# =========================================================================

# Ensure common tools are in PATH
export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"

# Paths
CACHE_FILE="$HOME/.cache/ambxst/kitty.conf"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"

# Exit if cache doesn't exist
if [[ ! -f $CACHE_FILE ]]; then
  exit 0
fi

# 1. Extract Core Colors from Kitty Cache
BG=$(grep "^background " "$CACHE_FILE" | awk '{print $2}')
FG=$(grep "^foreground " "$CACHE_FILE" | awk '{print $2}')
CURSOR=$(grep "^cursor " "$CACHE_FILE" | awk '{print $2}')
OPACITY=$(grep "^background_opacity " "$CACHE_FILE" | awk '{print $2}')

# Clean hex colors (remove # for some tools if needed, but we keep it for Alacritty)
if [[ -z $OPACITY ]]; then OPACITY="1.0"; fi

# 2. Create the base Ghostty Config
cat <<GHOST_EOF >"$GHOSTTY_CONFIG"
# =========================================================================
# GHOSTTY CONFIG (AUTO-SYNCED WITH AMBXST)
# =========================================================================

# Font & Shell
font-family = "JetBrains Mono Nerd Font"
font-size = 16
command = zsh

# Window & Transparency
window-padding-x = 21
window-padding-y = 21
window-decoration = false
confirm-close-surface = false
background-opacity = $OPACITY
background-blur = true

# Theme Colors
background = $BG
foreground = $FG
cursor-color = $CURSOR

# ANSI Palette (Syncs Starship)
GHOST_EOF

# 3. Create Alacritty Config (Live Sync)
mkdir -p "$HOME/.config/alacritty"
cat <<ALAC_EOF >"$ALACRITTY_CONFIG"
# =========================================================================
# ALACRITTY CONFIG (AUTO-SYNCED WITH AMBXST)
# =========================================================================

[font]
normal = { family = "JetBrains Mono Nerd Font", style = "Regular" }
size = 16

[window]
decorations = "None"
dynamic_padding = false
padding = { x = 0, y = 0 }
startup_mode = "Fullscreen"
opacity = $OPACITY

[colors.primary]
background = "$BG"
foreground = "$FG"

[colors.cursor]
cursor = "$CURSOR"

[colors.normal]
ALAC_EOF

# Extract normal palette
for i in {0..7}; do
  VAL=$(grep "^color$i " "$CACHE_FILE" | awk '{print $2}')
  case $i in
    0) NAME="black" ;; 1) NAME="red" ;; 2) NAME="green" ;; 3) NAME="yellow" ;;
    4) NAME="blue" ;; 5) NAME="magenta" ;; 6) NAME="cyan" ;; 7) NAME="white" ;;
  esac
  echo "$NAME = \"$VAL\"" >>"$ALACRITTY_CONFIG"
done

echo -e "\n[colors.bright]" >>"$ALACRITTY_CONFIG"
# Extract bright palette
for i in {8..15}; do
  VAL=$(grep "^color$i " "$CACHE_FILE" | awk '{print $2}')
  case $i in
    8) NAME="black" ;; 9) NAME="red" ;; 10) NAME="green" ;; 11) NAME="yellow" ;;
    12) NAME="blue" ;; 13) NAME="magenta" ;; 14) NAME="cyan" ;; 15) NAME="white" ;;
  esac
  echo "$NAME = \"$VAL\"" >>"$ALACRITTY_CONFIG"
done

# 4. Trigger live reload in Ghostty without closing it
pkill -USR2 ghostty 2>/dev/null || true
# Alacritty reloads automatically when the file is written!

# 5. Extract and format the full 16-color palette for Ghostty
grep "^color[0-9]* " "$CACHE_FILE" | while read -r line; do
  INDEX=$(echo "$line" | cut -d' ' -f1 | sed 's/color//')
  VALUE=$(echo "$line" | cut -d' ' -f2)
  echo "palette = $INDEX=$VALUE" >>"$GHOSTTY_CONFIG"
done

# =========================================================================
# DYNAMIC GTK & QT LIGHT/DARK THEME SWITCHER
# =========================================================================
if [[ -n $BG ]]; then
  # Strip leading '#' if present
  HEX="${BG#\#}"

  # Extract RGB values in Hexadecimal
  R_HEX="${HEX:0:2}"
  G_HEX="${HEX:2:2}"
  B_HEX="${HEX:4:2}"

  # Convert to decimal numbers
  R=$((16#$R_HEX))
  G=$((16#$G_HEX))
  B=$((16#$B_HEX))

  # Calculate relative brightness (standard formula: HSP Color Model)
  BRIGHTNESS=$(((R * 299 + G * 587 + B * 114) / 1000))

  if [[ $BRIGHTNESS -gt 127 ]]; then
    # ----------------- LIGHT MODE -----------------
    GTK_THEME="Breeze"
    COLOR_SCHEME="prefer-light"
    KDE_COLOR_SCHEME="BreezeLight"

    # Update dynamic GTK configurations at runtime
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Breeze' 2>/dev/null || true
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'" 2>/dev/null || true
  else
    # ----------------- DARK MODE ------------------
    GTK_THEME="Breeze-Dark"
    COLOR_SCHEME="prefer-dark"
    KDE_COLOR_SCHEME="BreezeDark"

    # Update dynamic GTK configurations at runtime
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Breeze-Dark' 2>/dev/null || true
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
  fi

  # Sync settings.ini files dynamically if they are mutable
  for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
    mkdir -p "$dir"
    settings_file="$dir/settings.ini"
    if [[ ! -f $settings_file ]]; then
      echo -e "[Settings]\ngtk-theme-name=$GTK_THEME\ngtk-application-prefer-dark-theme=1" >"$settings_file"
    else
      grep -q "gtk-theme-name=" "$settings_file" || echo "gtk-theme-name=$GTK_THEME" >>"$settings_file"
      grep -q "gtk-application-prefer-dark-theme=" "$settings_file" || echo "gtk-application-prefer-dark-theme=1" >>"$settings_file"

      sed -i "s/gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$settings_file" 2>/dev/null || true
      if [[ $COLOR_SCHEME == "prefer-dark" ]]; then
        sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=1/" "$settings_file" 2>/dev/null || true
      else
        sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=0/" "$settings_file" 2>/dev/null || true
      fi
    fi
  done

  # Sync KDE / QT ColorScheme settings dynamically at runtime
  kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$KDE_COLOR_SCHEME" 2>/dev/null || true

  # Sync Cursor Theme across active GTK configurations
  for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
    settings_file="$dir/settings.ini"
    if [[ -f $settings_file ]]; then
      grep -q "gtk-cursor-theme-name=" "$settings_file" || echo "gtk-cursor-theme-name=Bibata-Modern-Classic" >>"$settings_file"
      sed -i "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Bibata-Modern-Classic/" "$settings_file" 2>/dev/null || true
    fi
  done

  # 6. Dynamic Firefox & VLSI Dashboard Theme Sync
  FIREFOX_THEME_DIR="$HOME/.config/firefox"
  mkdir -p "$FIREFOX_THEME_DIR"
  cat <<FF_EOF >"$FIREFOX_THEME_DIR/theme.css"
/* =========================================================================
   FF THEME COLORS (AUTO-SYNCED WITH AMBXST SYSTEM COLORS)
   ========================================================================= */
:root {
  --bg-color: $BG !important;
  --fg-color: $FG !important;
  --accent-color: $CURSOR !important;
  --accent-glow: $CURSOR\34\30 !important; /* 25% opacity neon glow */
}
FF_EOF
fi
