{ config, pkgs, ... }:

{
  # --- XDG Config Files (The Nix Way) ---
  xdg.configFile = {
    # 1. Main Hyprland Entry Point
    "hypr/hyprland.lua".text = ''
      local home = os.getenv("HOME")
      local config_dir = home .. "/.config/hypr"
      local ambxst_core = home .. "/.local/share/ambxst/hyprland.lua"

      -- 1. SANITIZE CORE CONFIG (Fixes invalid gradient syntax for light themes)
      os.execute("sed -i 's/inactive_border = \"rgb(\\([0-9a-fA-F]*\\)) rgb(\\([0-9a-fA-F]*\\))\",/inactive_border = { colors = {\"rgb(\\1)\", \"rgb(\\2)\"}, angle = 45 },/' " .. ambxst_core)

      -- 2. SYNC TERMINAL THEMES (Instant update for Ghostty)
      os.execute("bash " .. home .. "/.local/bin/sync_ghostty.sh")

      -- 3. Environment Variables
      dofile(config_dir .. "/hyprland/env.lua")

      -- 4. Core Ambxst Logic
      dofile(ambxst_core)

      -- 5. Local Modular Overrides
      dofile(config_dir .. "/hyprland/env.lua")
      dofile(config_dir .. "/hyprland/input.lua")
      dofile(config_dir .. "/hyprland/execs.lua")
      dofile(config_dir .. "/hyprland/general.lua")
      dofile(config_dir .. "/hyprland/rules.lua")
      dofile(config_dir .. "/hyprland/keybinds.lua")
    '';

    # 2. Modular Files
    "hypr/hyprland/input.lua".text = ''
      -- ############ PROFESSIONAL INPUT & TOUCHPAD ############
      hl.config({
          input = {
              kb_layout = "us",
              follow_mouse = 1,
              sensitivity = 0,
              
              -- Professional typing experience
              off_window_axis_events = 1,
              
              touchpad = {
                  natural_scroll = true,
                  disable_while_typing = true,
                  tap_to_click = true,
                  clickfinger_behavior = true,
                  scroll_factor = 0.5,
              },
          },
          
          -- Cursor behavior
          cursor = {
              no_hardware_cursors = false,
              no_break_fs_vrr = false,
              min_refresh_rate = 60,
          },
      })
    '';

    "hypr/hyprland/env.lua".text = ''
      local home_dir = os.getenv("HOME")
      hl.env("XCURSOR_SIZE", "24")
      hl.env("HYPRCURSOR_SIZE", "24")
      hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
      hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
      hl.env("GDK_BACKEND", "wayland,x11")
      hl.env("QT_QPA_PLATFORM", "wayland;xcb")
      hl.env("SDL_VIDEODRIVER", "wayland,x11")
      hl.env("CLUTTER_BACKEND", "wayland")
      hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
      hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
      hl.env("QT_QPA_PLATFORMTHEME", "kde")
      hl.env("XDG_MENU_PREFIX", "plasma-")
      local xdg_data_dirs_old = os.getenv("XDG_DATA_DIRS") or ""
      hl.env("XDG_DATA_DIRS", home_dir .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share:" .. xdg_data_dirs_old)
    '';

    "hypr/hyprland/execs.lua".text = ''
      hl.on("hyprland.start", function()
          hl.exec_cmd("dbus-update-activation-environment --all")
          hl.exec_cmd("sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
          hl.exec_cmd("systemctl --user start hyprpolkitagent")
          hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
          hl.exec_cmd("bash $HOME/.local/bin/sync_ghostty.sh")
          hl.exec_cmd("hyprctl keyword windowrule 'dimaround, hyprpolkitagent'")
          hl.exec_cmd("sleep 5 && distrobox enter mayank-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/xic/xic &")
      end)
    '';

    "hypr/hyprland/general.lua".text = ''
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
      hl.config({
          gestures = {
              workspace_swipe_distance = 700,
              workspace_swipe_cancel_ratio = 0.2,
              workspace_swipe_min_speed_to_force = 5,
              workspace_swipe_direction_lock = true,
              workspace_swipe_direction_lock_threshold = 10,
              workspace_swipe_create_new = true
          }
      })
      hl.gesture({ fingers = 3, direction = "swipe", action = "move" })
      hl.gesture({ fingers = 3, direction = "pinch", action = "fullscreen" })
      hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
      hl.gesture({ fingers = 4, direction = "up", action = function() hl.dispatch(hl.dsp.exec_cmd("ambxst run overview")) end })
      hl.gesture({ fingers = 4, direction = "down", action = function() hl.dispatch(hl.dsp.exec_cmd("ambxst run overview")) end })
    '';

    "hypr/hyprland/rules.lua".text = ''
      hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })
      local floating_titles = {
          "^(Open File)(.*)$", "^(Select a File)(.*)$", "^(Choose wallpaper)(.*)$",
          "^(Open Folder)(.*)$", "^(Save As)(.*)$", "^(Library)(.*)$",
          "^(File Upload)(.*)$", "^(.*)(wants to save)$", "^(.*)(wants to open)$"
      }
      for _, title in ipairs(floating_titles) do
          hl.window_rule({ match = { title = title }, float = true })
          hl.window_rule({ match = { title = title }, center = true })
      end
      hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
      hl.window_rule({ match = { class = "^(pavucontrol)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
      hl.window_rule({ match = { class = "^(pavucontrol)$" }, center = true })
      hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
      hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
      hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, center = true })
      hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
      hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
      hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, center = true })
      hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, float = true })
      hl.window_rule({ match = { class = "kcm_.*" }, float = true })
      hl.window_rule({ match = { title = ".*Welcome" }, float = true })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, pin = true })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, move = { "(monitor_w*0.73)", "(monitor_h*0.72)" } })
      hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, size = { "(monitor_w*0.25)", "(monitor_h*0.25)" } })
      hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
      hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })
      hl.window_rule({ match = { float = 0 }, no_shadow = true })

      -- XPPen Tablet Driver (Force X11 compatibility in Hyprland)
      hl.window_rule({ match = { class = "pentablet" }, float = true })
      hl.window_rule({ match = { class = "pentablet" }, center = true })
      hl.window_rule({ match = { class = "pentablet" }, size = { "800", "600" } })

      -- ############ PREMIUM POLKIT PROMPT (High-End UI) ############
      -- This makes your password prompt look like a professional OS element
      hl.window_rule({ match = { class = "hyprpolkitagent" }, float = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, size = { "450", "250" } })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, center = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, pin = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, stay_focused = true })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, border_size = 2 })
      hl.window_rule({ match = { class = "hyprpolkitagent" }, rounding = 16 })
      
      -- Force Polkit to use ambxst active border color dynamically
      hl.window_rule({ match = { class = "hyprpolkitagent" }, no_shadow = false })

      -- Glass Effect for Polkit (Matches ambxst bar/menus)
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, blur = true })
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, blur_popups = true })
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, ignore_alpha = 0.5 })
      hl.layer_rule({ match = { namespace = "hyprpolkitagent" }, no_anim = false })

      hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })
    '';
    "hypr/hyprland/keybinds.lua".text = ''

      hl.bind("SUPER + Q", hl.dsp.window.close())
      hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
      hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"))
      hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("ambxst run tmux"))
      hl.bind("SUPER + ALT + Right", hl.dsp.exec_cmd("resizeactive 50 0"))
      hl.bind("SUPER + ALT + Left", hl.dsp.exec_cmd("resizeactive -50 0"))
      hl.bind("SUPER + ALT + Down", hl.dsp.exec_cmd("resizeactive 0 50"))
      hl.bind("SUPER + ALT + Up", hl.dsp.exec_cmd("resizeactive 0 -50"))
      hl.bind("Print", hl.dsp.exec_cmd("ambxst run screenshot"))
    '';
  };

  # --- Dynamic Theme Synchronization Engine ---
  # Deploys a customized executable to ~/.local/bin/sync_ghostty.sh which is run
  # automatically by Ambxst/Hyprland on every theme or wallpaper update.
  # It dynamically extracts colors from the active Ambxst configuration,
  # writes them to Ghostty/Starship, calculates the luminance of the new wallpaper,
  # and automatically switches system-wide GTK and QT apps between Dark/Light mode!
  home.file.".local/bin/sync_ghostty.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Ensure common tools are in PATH
      export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"

      # Paths
      CACHE_FILE="$HOME/.cache/ambxst/kitty.conf"
      GHOSTTY_CONFIG="$HOME/.config/ghostty/config"

      # Exit if cache doesn't exist
      if [[ ! -f "$CACHE_FILE" ]]; then
          exit 0
      fi

      # 1. Extract Core Colors from Kitty Cache
      BG=$(grep "^background " "$CACHE_FILE" | awk '{print $2}')
      FG=$(grep "^foreground " "$CACHE_FILE" | awk '{print $2}')
      CURSOR=$(grep "^cursor " "$CACHE_FILE" | awk '{print $2}')
      OPACITY=$(grep "^background_opacity " "$CACHE_FILE" | awk '{print $2}')

      # Fallback for opacity if not found
      if [[ -z "$OPACITY" ]]; then OPACITY="1.0"; fi

      # 2. Create the base Ghostty Config
      cat << GHOST_EOF > "$GHOSTTY_CONFIG"
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

      # 3. Extract and format the full 16-color palette
      grep "^color[0-9]* " "$CACHE_FILE" | while read -r line; do
          INDEX=$(echo "$line" | cut -d' ' -f1 | sed 's/color//')
          VALUE=$(echo "$line" | cut -d' ' -f2)
          echo "palette = $INDEX=$VALUE" >> "$GHOSTTY_CONFIG"
      done

      # 4. Trigger live reload in Ghostty without closing it
      pkill -USR2 ghostty 2>/dev/null || true

      # =========================================================================
      # DYNAMIC GTK & QT LIGHT/DARK THEME SWITCHER
      # =========================================================================
      if [[ -n "$BG" ]]; then
          # Strip leading '#' if present
          HEX="''${BG#\#}"
          
          # Extract RGB values in Hexadecimal
          R_HEX="''${HEX:0:2}"
          G_HEX="''${HEX:2:2}"
          B_HEX="''${HEX:4:2}"
          
          # Convert to decimal numbers
          R=$((16#$R_HEX))
          G=$((16#$G_HEX))
          B=$((16#$B_HEX))
          
          # Calculate relative brightness (standard formula: HSP Color Model)
          BRIGHTNESS=$(( (R * 299 + G * 587 + B * 114) / 1000 ))
          
          if [[ "$BRIGHTNESS" -gt 127 ]]; then
              # ----------------- LIGHT MODE -----------------
              GTK_THEME="Breeze"
              COLOR_SCHEME="prefer-light"
              KDE_COLOR_SCHEME="BreezeLight"
              
              # Update dynamic GTK configurations at runtime
              gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
              gsettings set org.gnome.desktop.interface gtk-theme 'Breeze' 2>/dev/null || true
          else
              # ----------------- DARK MODE ------------------
              GTK_THEME="Breeze-Dark"
              COLOR_SCHEME="prefer-dark"
              KDE_COLOR_SCHEME="BreezeDark"
              
              # Update dynamic GTK configurations at runtime
              gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
              gsettings set org.gnome.desktop.interface gtk-theme 'Breeze-Dark' 2>/dev/null || true
          fi
          
          # Sync settings.ini files dynamically if they are mutable
          for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
              mkdir -p "$dir"
              settings_file="$dir/settings.ini"
              if [[ ! -f "$settings_file" ]]; then
                  echo -e "[Settings]\ngtk-theme-name=$GTK_THEME\ngtk-application-prefer-dark-theme=1" > "$settings_file"
              else
                  grep -q "gtk-theme-name=" "$settings_file" || echo "gtk-theme-name=$GTK_THEME" >> "$settings_file"
                  grep -q "gtk-application-prefer-dark-theme=" "$settings_file" || echo "gtk-application-prefer-dark-theme=1" >> "$settings_file"
                  
                  sed -i "s/gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$settings_file" 2>/dev/null || true
                  if [[ "$COLOR_SCHEME" == "prefer-dark" ]]; then
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
              if [[ -f "$settings_file" ]]; then
                  grep -q "gtk-cursor-theme-name=" "$settings_file" || echo "gtk-cursor-theme-name=Bibata-Modern-Classic" >> "$settings_file"
                  sed -i "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=Bibata-Modern-Classic/" "$settings_file" 2>/dev/null || true
              fi
          done
      fi
    '';
  };

  # Install Bibata Cursors package locally so they can be loaded by Hyprland envs,
  # but without setting home.pointerCursor globally (so KDE stays untouched).
  home.packages = [
    pkgs.bibata-cursors
  ];
}
