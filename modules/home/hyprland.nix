{ config, pkgs, ... }:

{
  # --- XDG Config Files (The Nix Way) ---
  xdg.configFile = {
    # 0. Ambxst System/Idle Config (VLSI Protected)
    "ambxst/config/system.json".text = ''
      {
        "disks": [
          "/"
        ],
        "updateServiceEnabled": true,
        "idle": {
          "general": {
            "lock_cmd": "pkill -f 'alacritty --class manx-screensaver' || true; ambxst lock",
            "before_sleep_cmd": "loginctl lock-session",
            "after_sleep_cmd": "ambxst screen on"
          },
          "listeners": []
        },
        "ocr": {
          "eng": true,
          "spa": true,
          "lat": false,
          "jpn": false,
          "chi_sim": false,
          "chi_tra": false,
          "kor": false
        },
        "recorder": {
          "backend": "gpu-screen-recorder",
          "usePortal": true
        },
        "pomodoro": {
          "workTime": 1500,
          "restTime": 300,
          "autoStart": false,
          "syncSpotify": false
        }
      }
    '';

    # 1. Main Hyprland Entry Point
    "hypr/hyprland.lua".text = ''
      local home = os.getenv("HOME")
      local config_dir = home .. "/.config/hypr"
      local ambxst_core = home .. "/.local/share/ambxst/hyprland.lua"

      -- 1. SYNC TERMINAL THEMES (Instant update for Ghostty)
      os.execute("bash " .. home .. "/.local/bin/sync_ghostty.sh")

      -- 2. Environment Variables
      dofile(config_dir .. "/hyprland/env.lua")

      -- 3. Core Ambxst Logic
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
      hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
      hl.env("XDG_SESSION_TYPE", "wayland")
      hl.env("XDG_SESSION_DESKTOP", "Hyprland")
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
          hl.exec_cmd("sleep 5 && distrobox enter manx-vivado -- env _JAVA_AWT_WM_NONREPARENTING=1 /tools/Xilinx/xic/xic &")
      end)
    '';

    "hypr/hyprland/general.lua".text = ''
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
      hl.config({
          general = {
              resize_on_border = true,
          },
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

      -- ############ SILICON SECURITY SCREEN SAVER (Omarchy style) ############
      hl.window_rule({ match = { class = "manx-screensaver" }, float = true })
      hl.window_rule({ match = { class = "manx-screensaver" }, fullscreen = true })
      hl.window_rule({ match = { class = "manx-screensaver" }, no_anim = true })
      hl.window_rule({ match = { class = "manx-screensaver" }, no_shadow = true })

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
      hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
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
    source = ./scripts/sync_ghostty.sh;
  };

  # Install Bibata Cursors package locally so they can be loaded by Hyprland envs,
  # but without setting home.pointerCursor globally (so KDE stays untouched).
  home.packages = [
    pkgs.bibata-cursors
    pkgs.terminaltexteffects
    pkgs.chafa
  ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Secure direct lock with cool effects
        lock_cmd = "pkill -f 'alacritty --class manx-screensaver' || true; ambxst lock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "ambxst screen on";
      };

      listener = [
        {
          # 1. Dim Brightness (2.5 mins)
          timeout = 150;
          on-timeout = "ambxst brightness 10 -s";
          on-resume = "ambxst brightness -r";
        }
        {
          # 2. Launch Visual Screensaver (4 mins)
          timeout = 240;
          on-timeout = "pkill -f 'alacritty --class manx-screensaver' || true; ${config.home.homeDirectory}/.local/bin/manx-screensaver";
          on-resume = "pkill -f 'alacritty --class manx-screensaver' || true";
        }
        {
          # 3. Secure Lock (5 mins)
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          # 4. Power Save / Screen Off (5.5 mins)
          timeout = 330;
          on-timeout = "ambxst screen off";
          on-resume = "ambxst screen on";
        }
      ];
    };
  };

  # Ensure hypridle starts with the graphical session
  systemd.user.services.hypridle.Install.WantedBy = [ "graphical-session.target" ];

  # Custom Silicon Security Screensaver (Elite Omarchy style)
  home.file.".local/bin/manx-screensaver" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Omarchy-standard Screensaver Orchestrator

      # Ensure solid PATH for hypridle environment
      export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"

      # 0. PRE-FLIGHT CHECKS
      if ! command -v tte &>/dev/null; then exit 1; fi

      # Prevent multiple instances
      if pgrep -f "alacritty --class manx-screensaver" >/dev/null; then
          exit 0
      fi

      # 1. CHECK TOGGLE STATE
      # If this file exists, screensaver is manually disabled
      if [[ -f "$HOME/.local/state/omarchy/toggles/screensaver-off" ]]; then
          exit 0
      fi

      FORCE=false
      if [[ "$1" == "--force" ]]; then
          FORCE=true
      fi

      if [[ "$FORCE" == "false" ]]; then
          # 2. CHECK CAFFEINE / INHIBITION
          if [[ "$(axctl system is-inhibited 2>/dev/null)" == "\"true\"" ]] || \
             [[ "$(axctl system is-inhibited 2>/dev/null)" == "true" ]] || \
             [[ "$(axctl system is-system-inhibited 2>/dev/null)" == "\"true\"" ]] || \
             [[ "$(axctl system is-system-inhibited 2>/dev/null)" == "true" ]]; then
              echo "Inhibited by Ambxst/Caffeine."
              exit 0
          fi

          # 3. CHECK MEDIA
          if axctl system media-inhibit-check 2>/dev/null | grep -q '"count": [1-9]'; then
              echo "Inhibited by media."
              exit 0
          fi
      fi

      # 4. LAUNCH (Elite Mode)
      # We force LC_ALL=C for clean XKB handling
      LC_ALL=C alacritty --class manx-screensaver \
                --title Screensaver \
                -o "window.startup_mode='Fullscreen'" \
                -o "window.decorations='None'" \
                -o "colors.primary.background='#000000'" \
                -o "window.padding={x=0,y=0}" \
                -o "window.dynamic_padding=false" \
                -e "$HOME/.local/bin/manx-screensaver-run"
    '';
  };

  home.file.".local/bin/manx-screensaver-run" = {
    executable = true;
    text = ''
                     #!/usr/bin/env bash
                     # Screensaver Core Loop (Enhanced Omarchy Style)

                     # Ensure solid PATH
                     export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"

                     START_TIME=$(awk '{print int($1)}' /proc/uptime)
                     INITIAL_CURSOR=$(hyprctl cursorpos 2>/dev/null || echo "0, 0")

                     screensaver_in_focus() {
                         # Allow a grace period of 3 seconds at startup for Alacritty to map and focus
                         local uptime_s=$(awk '{print int($1)}' /proc/uptime)
                         local elapsed=$((uptime_s - START_TIME))
                         if [[ $elapsed -lt 3 ]]; then
                             return 0
                         fi

                         active_window=$(hyprctl activewindow -j | jq -r '.class' 2>/dev/null)
                         if [[ "$active_window" == "manx-screensaver" ]]; then
                             return 0
                         else
                             return 1
                         fi
                     }

                     cursor_moved() {
                         # Allow a grace period of 3 seconds before checking cursor movement
                         local uptime_s=$(awk '{print int($1)}' /proc/uptime)
                         local elapsed=$((uptime_s - START_TIME))
                         if [[ $elapsed -lt 3 ]]; then
                             return 1
                         fi

                         CURRENT_CURSOR=$(hyprctl cursorpos 2>/dev/null || echo "0, 0")
                         if [[ "$CURRENT_CURSOR" != "$INITIAL_CURSOR" ]]; then
                             return 0
                         else
                             return 1
                         fi
                     }

                     exit_screensaver() {
                         # Restore cursor
                         hyprctl keyword cursor:invisible false >/dev/null 2>&1
                         # Kill background processes
                         pkill -f "tte" >/dev/null 2>&1
                         pkill -f "alacritty --class manx-screensaver" >/dev/null 2>&1
                         exit 0
                     }

                     trap exit_screensaver SIGINT SIGTERM EXIT

                     # Hide cursor for immersion
                     hyprctl keyword cursor:invisible true >/dev/null 2>&1
                     sleep 0.5

                     # Branding Paths
                     LOGO_PATH="$HOME/.config/omarchy/branding/logo.png"
                     TEXT_PATH="$HOME/.config/omarchy/branding/screensaver.txt"
                     mkdir -p "$HOME/.config/omarchy/branding"

                     # 2. Start Animation (Bulletproof Loop)
                     while true; do
                         # Get terminal size for dynamic scaling
                         cols=$(tput cols)
                         rows=$(tput lines)

                         # --- LIVE DYNAMIC BRANDING GENERATION ---
                         if [[ -f "$LOGO_PATH" ]]; then
                             # Calculate optimal size (80% of screen width, 70% of height)
                             target_cols=$((cols * 8 / 10))
                             target_rows=$((rows * 7 / 10))
                             LOGO_TEXT=$(chafa --format=symbols --size=''${target_cols}x''${target_rows} "$LOGO_PATH")
                         elif [[ -f "$TEXT_PATH" ]]; then
                             # Read text and strip leading/trailing empty lines for perfect centering
                             LOGO_TEXT=$(awk 'NF {p=1} p' "$TEXT_PATH" | tac | awk 'NF {p=1} p' | tac)
                         else
                             # Calculate LIVE stats for every theme cycle
                             CPU_LOAD=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.1f%%", usage}')
                             MEM_USAGE=$(free -m | awk '/Mem:/ { printf "%.0f%%", $3/$2*100 }')

                             LOGO_TEXT=$(cat << EOF
                  ▄▄▄▄███▄▄▄▄      ▄████████ ▄██   ▄      ▄████████ ███▄▄▄▄      ▄█   ▄█▄ 
                ▄██▀▀▀███▀▀▀██▄   ███    ███ ███   ██▄   ███    ███ ███▀▀▀██▄   ███ ▄███▀ 
                ███   ███   ███   ███    ███ ███▄▄▄███   ███    ███ ███   ███   ███▐██▀   
                ███   ███   ███   ███    ███ ▀▀▀▀▀▀███   ███    ███ ███   ███  ▄█████▀    
                ███   ███   ███ ▀███████████ ▄██   ███ ▀███████████ ███   ███ ▀▀█████▄    
                ███   ███   ███   ███    ███ ███   ███   ███    ███ ███   ███   ███▐██▄   
                ███   ███   ███   ███    ███ ███   ███   ███    ███ ███   ███   ███ ▀███▄ 
                 ▀█   ███   █▀    ███    █▀   ▀█████▀    ███    █▀   ▀█   █▀    ███   ▀█▀ 
                                                                                ▀         
                        SILICON WORKSTATION SECURED
                   [ VLSI Simulation Pipeline Active ]

                   SYSTEM DASHBOARD:
                   CPU LOAD: $CPU_LOAD | RAM: $MEM_USAGE
                   STATUS: ENCRYPTED & PROTECTED
      EOF
      )
                         fi

                         # Select a random effect
                         effects=(
                             "beams" "binarypath" "blackhole" "bouncyballs" "bubbles" "burn"
                             "colorshift" "crumble" "decrypt" "errorcorrect" "expand" "fireworks"
                             "highlight" "laseretch" "matrix" "middleout" "orbittingvolley" "overflow"
                             "pour" "print" "rain" "randomsequence" "rings" "scattered" "slice"
                             "slide" "smoke" "spotlights" "spray" "swarm" "sweep" "synthgrid"
                             "thunderstorm" "unstable" "vhstape" "waves" "wipe"
                         )
                         effect=''${effects[$RANDOM % ''${#effects[@]}]}

                         # Start TTE animation with high-fidelity adaptive scaling and dual centering
                         # --canvas-width/height: Synchronizes TTE canvas with physical terminal dimensions
                         # --anchor-canvas c --anchor-text c: Ensures artwork is centered vertically and horizontally
                         echo "$LOGO_TEXT" | tte --frame-rate 60 --xterm-colors --no-restore-cursor \
                                                 --canvas-width "$cols" --canvas-height "$rows" \
                                                 --anchor-canvas c --anchor-text c \
                                                 --no-eol \
                                                 "$effect" &
                         TTE_PID=$!
                         # Interaction loop
                         while kill -0 "$TTE_PID" 2>/dev/null; do
                             if read -n 1 -t 0.1 || ! screensaver_in_focus || cursor_moved; then
                                 exit_screensaver
                             fi
                         done

                         sleep 1
                         clear
                     done
    '';
  };
}
