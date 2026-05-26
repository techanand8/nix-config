{
  config,
  pkgs,
  lib,
  ...
}:

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
          hl.exec_cmd("systemctl --user start graphical-session.target")
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

      -- ############ EDA & VLSI ENGINEERING TOOLING WINDOW RULES ############
      -- Float and center all secondary Vivado/Vitis popups and dialog windows
      hl.window_rule({ match = { class = "vivado", title = "^(?!Vivado).*$" }, float = true })
      hl.window_rule({ match = { class = "vivado", title = "^(?!Vivado).*$" }, center = true })
      hl.window_rule({ match = { class = "Vivado", title = "^(?!Vivado).*$" }, float = true })
      hl.window_rule({ match = { class = "Vivado", title = "^(?!Vivado).*$" }, center = true })

      -- Float physical design editors so they don't get squished by tiling layouts
      hl.window_rule({ match = { class = "magic" }, float = true })
      hl.window_rule({ match = { class = "klayout" }, float = true })
      hl.window_rule({ match = { class = "xschem" }, float = true })
      hl.window_rule({ match = { class = "gtkwave" }, float = true })

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
        lock_cmd = "ambxst lock";
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
          on-timeout = "${config.home.homeDirectory}/.local/bin/manx-screensaver";
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
      LOG_FILE="/tmp/manx-screensaver.log"

      # 0. PRE-FLIGHT
      if [[ -f "$HOME/.local/state/omarchy/toggles/screensaver-off" ]]; then
          echo "$(date): [Orchestrator] Disabled via toggle" >> "$LOG_FILE"
          exit 0
      fi

      # 1. CHECK INHIBITION
      if [[ "$1" != "--force" ]]; then
          if [[ "$(axctl system is-inhibited 2>/dev/null)" == "true" ]] || \
             [[ "$(axctl system is-inhibited 2>/dev/null)" == "\"true\"" ]] || \
             axctl system media-inhibit-check 2>/dev/null | grep -q '"count": [1-9]'; then
              echo "$(date): [Orchestrator] System inhibited" >> "$LOG_FILE"
              exit 0
          fi
      fi

      # 2. CLEANUP & LAUNCH
      ${pkgs.procps}/bin/pkill -f "alacritty --class manx-screensaver" || true
      sleep 0.2

      echo "$(date): [Orchestrator] Launching Alacritty..." >> "$LOG_FILE"
      LC_ALL=C ${pkgs.alacritty}/bin/alacritty --class manx-screensaver \
                --title Screensaver \
                -o "window.startup_mode='Fullscreen'" \
                -o "window.decorations='None'" \
                -o "colors.primary.background='#000000'" \
                --command "$HOME/.local/bin/manx-screensaver-run"
    '';
  };

  home.file.".local/bin/manx-screensaver-run" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Screensaver Core Loop (Elite Silicon Grade)
      LOG_FILE="/tmp/manx-screensaver.log"

      # Absolute tool paths for Nix stability
      HYPRCTL="${pkgs.hyprland}/bin/hyprctl"
      JQ="${pkgs.jq}/bin/jq"
      TTE="${pkgs.terminaltexteffects}/bin/tte"
      CHAFA="${pkgs.chafa}/bin/chafa"
      TPUT="${pkgs.ncurses}/bin/tput"
      PKILL="${pkgs.procps}/bin/pkill"
      FREE="${pkgs.procps}/bin/free"

      START_TIME=$(awk '{print int($1)}' /proc/uptime)
      INITIAL_CURSOR=$($HYPRCTL cursorpos 2>/dev/null || echo "0, 0")

      exit_screensaver() {
          local reason=$1
          echo "$(date): [Core] Exit triggered by: $reason" >> "$LOG_FILE"
          $HYPRCTL keyword cursor:invisible false >/dev/null 2>&1
          $PKILL -P $$ 2>/dev/null
          $PKILL -f "alacritty --class manx-screensaver" 2>/dev/null
          exit 0
      }

      trap "exit_screensaver 'Signal'" SIGINT SIGTERM EXIT
      $HYPRCTL keyword cursor:invisible true >/dev/null 2>&1

      echo "$(date): [Core] Started at $INITIAL_CURSOR" >> "$LOG_FILE"

      # Branding
      LOGO_PATH="$HOME/.config/omarchy/branding/logo.png"
      TEXT_PATH="$HOME/.config/omarchy/branding/screensaver.txt"

      while true; do
          cols=$($TPUT cols)
          rows=$($TPUT lines)

          if [[ -f "$LOGO_PATH" ]]; then
              target_cols=$((cols * 8 / 10))
              target_rows=$((rows * 7 / 10))
              LOGO_TEXT=$($CHAFA --format=symbols --size=''${target_cols}x''${target_rows} "$LOGO_PATH")
          elif [[ -f "$TEXT_PATH" ]]; then
              LOGO_TEXT=$(awk 'NF {p=1} p' "$TEXT_PATH" | tac | awk 'NF {p=1} p' | tac)
          else
              CPU=$(grep 'cpu ' /proc/stat | awk '{u=($2+$4)*100/($2+$4+$5)} END {printf "%.1f%%", u}')
              MEM=$($FREE -m | awk '/Mem:/ { printf "%.0f%%", $3/$2*100 }')
              LOGO_TEXT="⚡ MANX OS ⚡\n[ SILICON WORKSTATION ]\n\nCPU: $CPU | RAM: $MEM\nSTATUS: ENCRYPTED"
          fi

          effects=("beams" "binarypath" "blackhole" "bubbles" "burn" "colorshift" "matrix" "rain" "slide" "waves")
          effect=''${effects[$RANDOM % ''${#effects[@]}]}

          echo "$(date): [Core] Running $effect..." >> "$LOG_FILE"

          # Run TTE and capture errors to the main log
          echo -e "$LOGO_TEXT" | $TTE --frame-rate 60 --xterm-colors --no-restore-cursor \
                                      --canvas-width "$cols" --canvas-height "$rows" \
                                      --anchor-canvas c --anchor-text c --no-eol "$effect" 2>> "$LOG_FILE" &
          TTE_PID=$!

          # Interaction Loop
          while kill -0 "$TTE_PID" 2>/dev/null; do
              # 1. Keypress check
              if read -n 1 -t 0.1; then
                  exit_screensaver "Keypress"
              fi

              # Grace period for focus/cursor
              uptime_s=$(awk '{print int($1)}' /proc/uptime)
              if [[ $((uptime_s - START_TIME)) -gt 5 ]]; then
                  # 2. Focus check
                  active=$($HYPRCTL activewindow -j | $JQ -r '.class' 2>/dev/null)
                  if [[ "$active" != "manx-screensaver" ]]; then
                      exit_screensaver "Focus Lost (Active: $active)"
                  fi
                  # 3. Cursor check
                  current=$($HYPRCTL cursorpos 2>/dev/null || echo "0, 0")
                  if [[ "$current" != "$INITIAL_CURSOR" ]]; then
                      exit_screensaver "Cursor Move ($current)"
                  fi
              fi
          done

          sleep 0.5
          clear
      done
    '';
  };

}
