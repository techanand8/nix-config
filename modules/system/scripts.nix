{ pkgs, vars, ... }:

let
  manx-script = pkgs.writeShellApplication {
    name = "manx";
    runtimeInputs = with pkgs; [
      git
      nh
      nix
      nvd
      curl
      snapper
      util-linux # for findmnt and hostname
      coreutils
      gnugrep
      gnused
      findutils
      fzf
      bat
      libnotify
      xdg-utils
      python3
      onlyoffice-desktopeditors
      libreoffice
      procps
      alacritty
      cachix
      distrobox
      dbus # for machine-id
    ];
    text = ''
      # Advanced NixOS Management Utility
      # Custom-built for the MANX Engineering Workstation

      # --- DYNAMIC PORTABILITY ---
      if git rev-parse --is-inside-work-tree &>/dev/null; then
          CONFIG_DIR=$(git rev-parse --show-toplevel)
      else
          CONFIG_DIR="$HOME/nix-config"
      fi

      export FLAKE="$CONFIG_DIR"
      export NH_FLAKE="$CONFIG_DIR"
      export NIXPKGS_ALLOW_UNFREE=1

      # Smart Host Detection
      RAW_HOSTNAME=$(hostname)
      UPPER_HOST=$(echo "$RAW_HOSTNAME" | tr '[:lower:]' '[:upper:]' || echo "MANX")

      if [[ "$UPPER_HOST" == *LAPTOP* ]]; then
          HOSTNAME="LAPTOP"
          HOST_DIR="laptop"
      elif [[ "$UPPER_HOST" == *MANX* ]]; then
          HOSTNAME="MANX"
          HOST_DIR="manx"
      else
          HOSTNAME="MANX"
          HOST_DIR="manx"
      fi

      BRAND_NAME="MANX"
      EDITOR="nvim"
      VIVADO_VERSION="${vars.vivadoVersion}"

      # --- COLOR PALETTE ---
      C_PRIMARY='\033[38;5;208m'   # Coral Orange
      C_SECONDARY='\033[38;5;99m'  # Royal Soft Purple
      C_HIGHLIGHT='\033[38;5;43m'  # Vibrant Teal
      C_SUCCESS='\033[38;5;76m'    # Emerald Green
      C_MUTED='\033[38;5;244m'     # Dim Grey
      C_WHITE='\033[1;37m'         # Bright White
      C_GOLD='\033[38;5;220m'      # Warm Gold
      RED='\033[1;31m'
      NC='\033[0m'

      function log() { echo -e "''${C_SECONDARY}  [SYSTEM]''${NC} $1"; }
      function error() { echo -e "''${RED}󰅚  [ERROR]''${NC} $1"; exit 1; }
      function success() { echo -e "''${C_SUCCESS}󰄬  [SUCCESS]''${NC} $1"; }
      function info() { echo -e "''${C_HIGHLIGHT}󰌢  [INFO]''${NC} $1"; }

      function show_help() {
          local uptime_all uptime_seconds days hours mins uptime_str
          uptime_all=$(cat /proc/uptime)
          uptime_seconds=''${uptime_all%%.*}
          days=$((uptime_seconds / 86400))
          hours=$(( (uptime_seconds % 86400) / 3600 ))
          mins=$(( (uptime_seconds % 3600) / 60 ))
          uptime_str=""
          if [ "$days" -gt 0 ]; then uptime_str+="$days""d "; fi
          if [ "$hours" -gt 0 ]; then uptime_str+="$hours""h "; fi
          uptime_str+="$mins""m"

          echo -e ""
          echo -e "  ''${C_PRIMARY}󱄅''${NC}  ''${C_WHITE}''$BRAND_NAME   W O R K S T A T I O N''${NC}  ''${C_MUTED}│''${NC}  ''${C_SECONDARY}''${NC}  ''${C_GOLD}NIXOS SYSTEM''${NC}"
          echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
          echo -e "  ''${C_HIGHLIGHT}  Host:''${NC} ''${C_WHITE}''$HOSTNAME''${NC}         ''${C_HIGHLIGHT}󰓅  Uptime:''${NC} ''${C_WHITE}''$uptime_str''${NC}"
          echo -e "  ''${C_HIGHLIGHT}  Kernel:''${NC} ''${C_WHITE}''$(uname -r)''${NC}       ''${C_HIGHLIGHT}  Status:''${NC} ''${C_SUCCESS}Online''${NC}"
          echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
          echo -e ""
          echo -e "  ''${C_SECONDARY}Usage:''${NC} ''${C_WHITE}manx''${NC} ''${C_GOLD}<command>''${NC}"
          echo -e ""
          echo -e "  ''${C_PRIMARY}󰓅  CONFIGURATION MANAGEMENT''${NC}"
          echo -e "    ''${C_WHITE}rebuild''${NC}   ''${C_MUTED}❯''${NC} Synchronize adjustments and show package changes"
          echo -e "    ''${C_WHITE}update''${NC}    ''${C_MUTED}❯''${NC} Update system inputs and perform full build"
          echo -e "    ''${C_WHITE}rollback''${NC}  ''${C_MUTED}❯''${NC} Revert to previous successful generation"
          echo -e "    ''${C_WHITE}history''${NC}   ''${C_MUTED}❯''${NC} List detailed system generations"
          echo -e ""
          echo -e "  ''${C_PRIMARY}󰌢  MAINTENANCE & SECURITY''${NC}"
          echo -e "    ''${C_WHITE}clean''${NC}     ''${C_MUTED}❯''${NC} Execute deep system maintenance protocols"
          echo -e "    ''${C_WHITE}check''${NC}     ''${C_MUTED}❯''${NC} Validate configuration health and integrity"
          echo -e "    ''${C_WHITE}bootstrap''${NC} ''${C_MUTED}❯''${NC} Setup Btrfs blank subvolumes & secrets keypaths"
          echo -e "    ''${C_WHITE}doctor''${NC}    ''${C_MUTED}❯''${NC} Diagnostic system health, Flakes, & packages check"
          echo -e ""
          echo -e "  ''${C_PRIMARY}󰏆  PRODUCTIVITY & DOCS''${NC}"
          echo -e "    ''${C_WHITE}word''${NC}      ''${C_MUTED}❯''${NC} Launch the professional OnlyOffice suite"
          echo -e "    ''${C_WHITE}writer''${NC}    ''${C_MUTED}❯''${NC} Digital Technical Documentation (LibreOffice)"
          echo -e "    ''${C_WHITE}calc''${NC}      ''${C_MUTED}❯''${NC} Engineering Analysis & Spreadsheets"
          echo -e "    ''${C_WHITE}impress''${NC}   ''${C_MUTED}❯''${NC} Silicon Design Technical Presentations"
          echo -e "    ''${C_WHITE}draw''${NC}      ''${C_MUTED}❯''${NC} Schematic & Logic Flow Diagrams"
          echo -e ""
          echo -e "  ''${C_PRIMARY}  DEVELOPMENT UTILITIES''${NC}"
          echo -e "    ''${C_WHITE}edit''${NC}      ''${C_MUTED}❯''${NC} Interactive fuzzy-find or direct file edit"
          echo -e "    ''${C_WHITE}search''${NC}    ''${C_MUTED}❯''${NC} Query the Nixpkgs software registry"
          echo -e "    ''${C_WHITE}shell''${NC}     ''${C_MUTED}❯''${NC} Initialize isolated package environments"
          echo -e "    ''${C_WHITE}aider''${NC}     ''${C_MUTED}❯''${NC} High-Fidelity Engineering Agent (DeepSeek-16B)"
          echo -e "    ''${C_WHITE}agent''${NC}     ''${C_MUTED}❯''${NC} Local Execution Agent (Does computer tasks for you)"
          echo -e "    ''${C_WHITE}webui''${NC}     ''${C_MUTED}❯''${NC} Local Intelligence Interface (Professional Web-UI)"
          echo -e "    ''${C_WHITE}vivado''${NC}    ''${C_MUTED}❯''${NC} Enter the AMD Vivado design environment"
          echo -e "    ''${C_WHITE}routine''${NC}   ''${C_MUTED}❯''${NC} Launch Silicon Routine & Self-Improvement Dashboard"
          echo -e ""
          echo -e "  ''${C_PRIMARY}󰪢  BRANDING & AESTHETICS''${NC}"
          echo -e "    ''${C_WHITE}screensaver''${NC} ''${C_MUTED}❯''${NC} Orchestrate immersive workstation branding"
          echo -e "    ''${C_WHITE}showcase''${NC}    ''${C_MUTED}❯''${NC} Launch the secure static Workstation Showcase website"
          echo -e ""
          echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
          echo -e "  ''${C_HIGHLIGHT}󰌢  Type 'man manx' to access the system documentation.''${NC}"
          echo -e ""
      }

      if [ ! -d "$CONFIG_DIR/.git" ]; then
          info "Initializing configuration tracking repository..."
          git init "$CONFIG_DIR" > /dev/null
      fi

      if [ -z "''${1:-}" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
          show_help
          exit 0
      fi

      cd "$CONFIG_DIR"

      case $1 in
        rebuild)
          log "Executing system synchronization..."
          cleanup_secrets() {
              git reset -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true
          }
          trap cleanup_secrets EXIT SIGINT SIGTERM
          if command -v snapper &> /dev/null; then
              log "Creating pre-rebuild snapshots (Time Machine)..."
              sudo snapper -c home create --description "Pre-rebuild home snapshot" || true
          fi
          nix fmt
          git add -f -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true
          git add . &> /dev/null || true
          log "Validating configuration health..."
          CHECK_ERR=$(mktemp)
          if ! nix flake check . 2>"$CHECK_ERR"; then
              grep -v -E "incompatible systems|all-systems" "$CHECK_ERR" >&2 || true
              rm -f "$CHECK_ERR"
              cleanup_secrets
              error "Configuration audit failed. Please resolve errors before rebuilding."
          else
              grep -v -E "incompatible systems|all-systems" "$CHECK_ERR" >&2 || true
              rm -f "$CHECK_ERR"
          fi
          sudo mkdir -p /var/lib/open-webui
          sudo chown open-webui:open-webui /var/lib/open-webui 2>/dev/null || true
          GH_TOKEN=""
          [ -f "$HOME/.config/manx/github_token" ] && GH_TOKEN=$(cat "$HOME/.config/manx/github_token")
          GEMINI_TOKEN=""
          [ -f "$HOME/.config/manx/gemini_token" ] && GEMINI_TOKEN=$(cat "$HOME/.config/manx/gemini_token")
          log "Synchronizing secure AI API keys with Open-WebUI..."
          sudo mkdir -p /var/lib/open-webui
          sudo chown open-webui:open-webui /var/lib/open-webui
          sudo chmod 755 /var/lib/open-webui
          {
              echo "OLLAMA_BASE_URL=http://127.0.0.1:11434"
              echo "OLLAMA_API_BASE_URL=http://127.0.0.1:11434"
              echo "ENABLE_OLLAMA_API=True"
              if [ -n "$GH_TOKEN" ]; then
                  echo "OPENAI_API_BASE_URL=https://models.github.ai/inference/v1"
                  echo "OPENAI_API_KEY=$GH_TOKEN"
                  echo "ENABLE_OPENAI_API=True"
              else
                  echo "ENABLE_OPENAI_API=False"
              fi
              if [ -n "$GEMINI_TOKEN" ]; then
                  echo "GOOGLE_API_KEY=$GEMINI_TOKEN"
                  echo "ENABLE_GOOGLE_API=True"
              else
                  echo "ENABLE_GOOGLE_API=False"
              fi
          } | sudo tee /var/lib/open-webui/open-webui.env > /dev/null
          sudo chown open-webui:open-webui /var/lib/open-webui/open-webui.env
          sudo chmod 600 /var/lib/open-webui/open-webui.env
          sudo systemctl restart open-webui || true
          log "Applying system updates..."
          OLD_GEN=$(readlink -f /nix/var/nix/profiles/system 2>/dev/null || echo "/run/current-system")
          if ! nh os switch path:. --hostname "$HOSTNAME" -- --accept-flake-config; then
              cleanup_secrets
              error "System rebuild failed."
          fi
          log "Applying final filesystem permissions for Open-WebUI..."
          sudo chown -R open-webui:open-webui /var/lib/open-webui 2>/dev/null || true
          sudo chmod -R 755 /var/lib/open-webui 2>/dev/null || true
          sudo chmod 600 /var/lib/open-webui/open-webui.env 2>/dev/null || true
          sudo systemctl restart open-webui || true
          cleanup_secrets
          if [ -d "/persist/var/lib/sddm" ]; then
              log "Clearing SDDM persistent cache for theme synchronization..."
              sudo rm -rf /persist/var/lib/sddm/* &> /dev/null || true
          fi
          NEW_GEN=$(readlink -f /nix/var/nix/profiles/system 2>/dev/null || echo "/run/current-system")
          echo -e "\n''${C_HIGHLIGHT}  Package Changes:''${NC}"
          ( nvd diff "$OLD_GEN" "$NEW_GEN" || true )
          cleanup_secrets
          if git status --porcelain | grep -q '^[ MADRCU]'; then
              log "Recording system state to Git history..."
              echo -e "\n''${C_MUTED}Change Summary:''${NC}"
              git diff --stat --staged
              git commit -m "System Update: $(date '+%Y-%m-%d %H:%M')" &> /dev/null || true
          fi
          if git remote | grep -q "origin"; then
              log "Synchronizing configuration with GitHub..."
              PUSH_OUTPUT=$(git push origin main 2>&1) || true
              if [ -z "$PUSH_OUTPUT" ] || echo "$PUSH_OUTPUT" | grep -q "Everything up-to-date"; then
                  info "GitHub already up-to-date."
              elif echo "$PUSH_OUTPUT" | grep -q -E "To |Update|master ->|main ->"; then
                  success "GitHub synchronization complete."
              else
                  info "GitHub synchronization completed or skipped."
                  # shellcheck disable=SC2001
                  echo "$PUSH_OUTPUT" | sed 's/^/  /'
              fi
          fi
          CACHIX_NAME="${vars.cachixName}"
          if [ "$CACHIX_NAME" != "your-cachix-subdomain" ]; then
              log "Pushing system build to Cachix ($CACHIX_NAME)..."
              cachix push "$CACHIX_NAME" "$NEW_GEN" &> /dev/null || true
          fi
          success "System configuration applied successfully."
          ;;

        update)
          log "Updating system inputs..."
          nh os switch path:. --update --hostname "$HOSTNAME" || error "System update failed."
          success "System updated and synchronized."
          ;;

        clean)
          log "Performing deep system maintenance..."
          nh clean all --keep 3
          sudo nix-collect-garbage -d
          nix-collect-garbage -d
          sudo nix-store --optimise
          success "System maintenance complete."
          ;;

        bootstrap)
          log "Initializing Stateless Btrfs & SOPS Environment..."
          if findmnt -n -o FSTYPE / 2>/dev/null | grep -q "btrfs" || findmnt -n -o FSTYPE /persist 2>/dev/null | grep -q "btrfs"; then
              log "Btrfs file system verified."
              DEV_PATH=$(findmnt -n -o SOURCE /persist 2>/dev/null || findmnt -n -o SOURCE / 2>/dev/null || true)
              if [ -n "$DEV_PATH" ]; then
                  log "Discovered Btrfs device: ''$DEV_PATH"
                  mkdir -p /tmp/btrfs-root
                  if sudo mount -t btrfs -o subvolid=5 "''$DEV_PATH" /tmp/btrfs-root &>/dev/null; then
                      log "Mounted Btrfs root successfully."
                      if [ ! -d "/tmp/btrfs-root/blank" ]; then
                          info "Creating pristine '/blank' subvolume..."
                          sudo btrfs subvolume create /tmp/btrfs-root/blank
                      fi
                      sudo umount /tmp/btrfs-root
                      rm -rf /tmp/btrfs-root
                  fi
              fi
          fi
          if [ -d "/persist" ]; then
              log "Verifying SOPS and machine-id..."
              sudo mkdir -p "/persist/var/lib/sops-nix"
              sudo chmod 0700 "/persist/var/lib/sops-nix"
              if [ ! -f "/persist/etc/machine-id" ]; then
                  sudo mkdir -p /persist/etc
                  systemd-machine-id-setup | sudo tee /persist/etc/machine-id > /dev/null
              fi
          fi
          success "Bootstrap process completed."
          ;;

        word) onlyoffice-desktopeditors &> /dev/null & disown ;;
        writer) libreoffice --writer &> /dev/null & disown ;;
        calc) libreoffice --calc &> /dev/null & disown ;;
        impress) libreoffice --impress &> /dev/null & disown ;;
        draw) libreoffice --draw &> /dev/null & disown ;;

        edit)
          if [ -n "''${2:-}" ]; then
              if [ -f "''${2}" ]; then "$EDITOR" "''${2}"; else error "File not found: ''${2}"; fi
          else
              if command -v fzf &> /dev/null; then
                  log "Launching interactive configuration navigator..."
                  FILE=$(find . -maxdepth 4 \( -name "*.nix" -o -name "*.yaml" \) -not -path '*/.*' | fzf --preview "bat --color=always --style=numbers {}" --height 80% --layout=reverse --border --prompt="󱄅 Edit Config ❯ ")
                  if [ -n "''$FILE" ]; then "$EDITOR" "''$FILE"; else info "No file selected. Exiting."; fi
              else
                  "$EDITOR" hosts/"$HOST_DIR"/configuration.nix
              fi
          fi
          ;;

        search) shift; log "Querying Nixpkgs registry for: $*"; nh search "$@" ;;
        
        check)
          log "Auditing configuration health..."
          cleanup_secrets() { git reset -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true; }
          trap cleanup_secrets EXIT SIGINT SIGTERM
          git add -f -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true
          CHECK_ERR=$(mktemp)
          if ! nix flake check . 2>"''$CHECK_ERR"; then
              grep -v -E "incompatible systems|all-systems" "''$CHECK_ERR" >&2 || true
              rm -f "''$CHECK_ERR"
              cleanup_secrets
              error "Configuration audit failed."
          else
              grep -v -E "incompatible systems|all-systems" "''$CHECK_ERR" >&2 || true
              rm -f "''$CHECK_ERR"
              success "Configuration verified."
          fi
          ;;

        shell) shift; log "Entering shell for: $*"; nix-shell -p "$@" ;;

        aider)
          log "Initializing Aider Coding Workspace..."
          check_ollama() { if ! curl -s http://127.0.0.1:11434 &>/dev/null; then error "Ollama service is not running!"; fi; }
          if [ -z "''${2:-}" ] || [[ "$2" == -* ]]; then
              if command -v fzf &> /dev/null; then
                  log "Select a coding model for Aider (Local or Free Cloud):"
                  CHOICE=$(echo -e "qwen2.5-coder:7b (Recommended Local)\ndeepseek-coder:6.7b (Stable Local)\nanthropic/claude-3-5-sonnet (Elite Cloud Claude)\ngithub/gpt-4o (Free Cloud GPT-4o)\ngemini/gemini-1.5-pro (Elite Free Gemini)\nEnter Custom Ollama..." | fzf --height 45% --layout=reverse --border --prompt="󰏆 Select Coding Model ❯ ")
                  if [ -z "''$CHOICE" ]; then exit 0; fi
                  if [[ "''$CHOICE" == "Enter Custom Ollama..." ]]; then
                      echo -ne "  ''${C_HIGHLIGHT}❯ Enter Ollama model name:''${NC} "; read -r MODEL
                      [ -z "''$MODEL" ] && error "No model name entered."
                  else MODEL=$(echo "''$CHOICE" | cut -d' ' -f1); fi
              else MODEL="qwen2.5-coder:7b"; fi
          else MODEL="$2"; fi
          shift; [ "''${1:-}" == "''$MODEL" ] && shift
          
          if [[ "''$MODEL" == gemini/* ]]; then
              export GEMINI_API_KEY; GEMINI_API_KEY=$(cat "$HOME/.config/manx/gemini_token" 2>/dev/null || echo "''${GOOGLE_API_KEY:-}")
              if [ -z "''$GEMINI_API_KEY" ]; then echo -ne "  ''${C_HIGHLIGHT}❯ Enter your Google AI Studio API Key:''${NC} "; read -s -r USER_TOKEN; echo ""; export GEMINI_API_KEY="''$USER_TOKEN"; fi
              [ -z "''$GEMINI_API_KEY" ] && error "A Gemini API Key is required."
              log "Launching Free Gemini Agent (Aider + ''$MODEL)..."; aider --model "''$MODEL" --no-browser --map-tokens 1024 --edit-format whole --watch-files "$@"
          elif [[ "''$MODEL" == anthropic/* ]]; then
              export ANTHROPIC_API_KEY; ANTHROPIC_API_KEY=$(cat "$HOME/.config/manx/anthropic_token" 2>/dev/null || echo "''${ANTHROPIC_API_KEY:-}")
              if [ -z "''$ANTHROPIC_API_KEY" ]; then echo -ne "  ''${C_HIGHLIGHT}❯ Enter your Anthropic API Key:''${NC} "; read -s -r USER_TOKEN; echo ""; export ANTHROPIC_API_KEY="''$USER_TOKEN"; fi
              [ -z "''$ANTHROPIC_API_KEY" ] && error "An Anthropic API Key is required."
              log "Launching Elite Claude Agent (Aider + ''$MODEL)..."; aider --model "''$MODEL" --no-browser --map-tokens 1024 --edit-format whole --watch-files "$@"
          elif [[ "''$MODEL" == github/* ]]; then
              RAW_MODEL=$(echo "''$MODEL" | cut -d'/' -f2); export GITHUB_TOKEN; GITHUB_TOKEN=$(cat "$HOME/.config/manx/github_token" 2>/dev/null || echo "''${GITHUB_TOKEN:-}")
              if [ -z "''$GITHUB_TOKEN" ]; then echo -ne "  ''${C_HIGHLIGHT}❯ Enter your GitHub PAT:''${NC} "; read -s -r USER_TOKEN; echo ""; export GITHUB_TOKEN="''$USER_TOKEN"; fi
              [ -z "''$GITHUB_TOKEN" ] && error "A GitHub Token is required."
              export OPENAI_API_KEY="''$GITHUB_TOKEN"; export OPENAI_API_BASE="https://models.github.ai/inference/v1"
              log "Launching Free Cloud Agent (Aider + ''$RAW_MODEL)..."; aider --model "openai/''$RAW_MODEL" --no-browser --map-tokens 1024 --edit-format whole --watch-files "$@"
          else
              check_ollama; if ! ollama list 2>/dev/null | grep -q "''$MODEL"; then info "Model '''$MODEL' not found. Downloading..."; ollama pull "''$MODEL"; fi
              export OLLAMA_API_BASE="http://127.0.0.1:11434"
              log "Launching High-Fidelity Local Agent (Aider + ''$MODEL)..."; aider --model "ollama/''$MODEL" --no-browser --map-tokens 1024 --edit-format whole --watch-files "$@"
          fi
          ;;

        agent)
          log "Initializing Agent Workspace..."
          shift
          case "''${1:-}" in
            update)
              log "Self-healing Agent Environment..."
              nix-shell -p python312 pipx gcc rustc cargo --run "pipx install --python python3.12 --force open-interpreter && pipx runpip open-interpreter install 'setuptools<70'"
              success "Agent brain updated!"
              ;;
            *)
              if [ -z "''${1:-}" ] || [[ "$1" == -* ]]; then
                  if command -v fzf &> /dev/null; then
                      log "Select a model for Agent (Local or Free Cloud):"
                      CHOICE=$(echo -e "llama3.1:8b (Local Ollama Llama)\nqwen2.5-coder:7b (Local Ollama Qwen)\nanthropic/claude-3-5-sonnet (Elite Cloud Claude)\ngithub/gpt-4o (Free Cloud GPT-4o)\ngemini/gemini-1.5-pro (Elite Free Gemini)\nEnter Custom Ollama..." | fzf --height 45% --layout=reverse --border --prompt="󰏆 Select Agent Model ❯ ")
                      if [ -z "''$CHOICE" ]; then exit 0; fi
                      if [[ "''$CHOICE" == "Enter Custom Ollama..." ]]; then echo -ne "  ❯ Enter Ollama model name: "; read -r MODEL; else MODEL=$(echo "''$CHOICE" | cut -d' ' -f1); fi
                  else MODEL="llama3.1"; fi
              else MODEL="$1"; shift; fi
              
              if [[ "''$MODEL" == gemini/* ]]; then
                  export GEMINI_API_KEY; GEMINI_API_KEY=$(cat "$HOME/.config/manx/gemini_token" 2>/dev/null || echo "''${GOOGLE_API_KEY:-}")
                  log "Launching Free Gemini Agent (Open-Interpreter + ''$MODEL)..."; interpreter --model "''$MODEL" "$@"
              elif [[ "''$MODEL" == anthropic/* ]]; then
                  export ANTHROPIC_API_KEY; ANTHROPIC_API_KEY=$(cat "$HOME/.config/manx/anthropic_token" 2>/dev/null || echo "''${ANTHROPIC_API_KEY:-}")
                  log "Launching Elite Claude Agent (Open-Interpreter + ''$MODEL)..."; interpreter --model "''$MODEL" "$@"
              elif [[ "''$MODEL" == github/* ]]; then
                  RAW_MODEL=$(echo "''$MODEL" | cut -d'/' -f2); export GITHUB_TOKEN; GITHUB_TOKEN=$(cat "$HOME/.config/manx/github_token" 2>/dev/null || echo "''${GITHUB_TOKEN:-}")
                  export OPENAI_API_KEY="''$GITHUB_TOKEN"; export OPENAI_API_BASE="https://models.github.ai/inference/v1"
                  log "Launching Free Cloud Agent (Open-Interpreter + ''$RAW_MODEL)..."; interpreter --model "openai/''$RAW_MODEL" --api_base "''$OPENAI_API_BASE" "$@"
              else
                  check_ollama; export OLLAMA_API_BASE="http://127.0.0.1:11434"
                  log "Launching Local Agent (Open-Interpreter + ''$MODEL)..."; interpreter --local --model "ollama/''$MODEL" --no-llm_supports_functions --api_base http://127.0.0.1:11434 "$@"
              fi
              ;;
          esac
          ;;

        doctor)
          (
              set +e
              log "Running System Diagnostic Suite..."
              echo ""
              FLAKES_VAL=$(nix flake --help &>/dev/null && echo "✔" || echo "✗")
              CHANNELS_VAL=$([ -z "$(nix-channel --list 2>/dev/null)" ] && echo "✔" || echo "⚠")
              NH_VAL=$(command -v nh &>/dev/null && echo "✔" || echo "✗")
              RG_VAL=$(command -v rg &>/dev/null && echo "✔" || echo "✗")
              FZF_VAL=$(command -v fzf &>/dev/null && echo "✔" || echo "✗")
              GIT_VAL=$(command -v git &>/dev/null && echo "✔" || echo "✗")
              OLLAMA_VAL=$(curl -s http://127.0.0.1:11434 &>/dev/null && echo "✔" || echo "✗")
              WEBUI_VAL=$(curl -s http://127.0.0.1:8081 &>/dev/null && echo "✔" || echo "✗")
              TOKEN_VAL=$([ -s "$HOME/.config/manx/github_token" ] && echo "✔" || echo "✗")
              print_diag() {
                  local icon color label info
                  icon="''$1"; color="''$2"; label="''$3"; info="''$4"
                  printf "    [%b%s%b] %-22s %b❯%b  %b%s%b\n" "''$color" "''$icon" "''${NC}" "''$label" "''${C_MUTED}" "''${NC}" "''${C_WHITE}" "''$info" "''${NC}"
              }
              echo -e "  ''${C_PRIMARY}󰌢''${NC}  ''${C_WHITE}M A N X   S Y S T E M   D O C T O R''${NC}"
              echo -e "  ''${C_MUTED}────────────────────────────────────────────────────────────────────────''${NC}"
              echo -e "\n  ''${C_SECONDARY}  NixOS Base Environment''${NC}"
              print_diag "''$FLAKES_VAL" "''$([ "''$FLAKES_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "Flakes Enablement" "''$([ "''$FLAKES_VAL" == "✔" ] && echo "Active (Modern standard)" || echo "Disabled")"
              print_diag "''$CHANNELS_VAL" "''$([ "''$CHANNELS_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$C_GOLD")" "Declarative State" "''$([ "''$CHANNELS_VAL" == "✔" ] && echo "Pure (No channel pollution)" || echo "Legacy (Active)")"
              echo -e "\n  ''${C_SECONDARY}  Core System CLI Packages''${NC}"
              print_diag "''$NH_VAL" "''$([ "''$NH_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "nh (Nix Helper)" "''$([ "''$NH_VAL" == "✔" ] && echo "Present" || echo "MISSING")"
              print_diag "''$RG_VAL" "''$([ "''$RG_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "ripgrep (rg)" "''$([ "''$RG_VAL" == "✔" ] && echo "Present" || echo "MISSING")"
              print_diag "''$FZF_VAL" "''$([ "''$FZF_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "fzf finder" "''$([ "''$FZF_VAL" == "✔" ] && echo "Present" || echo "MISSING")"
              print_diag "''$GIT_VAL" "''$([ "''$GIT_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "git control" "''$([ "''$GIT_VAL" == "✔" ] && echo "Present" || echo "MISSING")"
              echo -e "\n  ''${C_HIGHLIGHT}󰌢  System Services & Keys''${NC}"
              print_diag "''$OLLAMA_VAL" "''$([ "''$OLLAMA_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "Ollama Service" "''$([ "''$OLLAMA_VAL" == "✔" ] && echo "Running on port 11434" || echo "OFFLINE / NOT STARTED")"
              print_diag "''$WEBUI_VAL" "''$([ "''$WEBUI_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "Open-WebUI Portal" "''$([ "''$WEBUI_VAL" == "✔" ] && echo "Running on port 8081" || echo "OFFLINE / NOT STARTED")"
              print_diag "''$TOKEN_VAL" "''$([ "''$TOKEN_VAL" == "✔" ] && echo "''$C_SUCCESS" || echo "''$RED")" "Secure GH Token" "''$([ "''$TOKEN_VAL" == "✔" ] && echo "Present & Secure (~/.config/manx/)" || echo "MISSING (No key found)")"
              if [ "''$NH_VAL" == "✗" ] || [ "''$OLLAMA_VAL" == "✗" ] || [ "''$TOKEN_VAL" == "✗" ] || [ "''$RG_VAL" == "✗" ] || [ "''$FZF_VAL" == "✗" ] || [ "''$GIT_VAL" == "✗" ]; then
                  echo -e "\n  ''${C_GOLD}󰋗  RECOMMENDED RESOLUTION ACTIONS:''${NC}"
                  echo -e "  ''${C_MUTED}────────────────────────────────────────────────────────────────────────''${NC}"
                  [ "''$RG_VAL" == "✗" ] && echo -e "    ''${C_MUTED}•''${NC} ''${C_WHITE}ripgrep missing''${NC}  ''${C_MUTED}❯''${NC} Add ''${C_GOLD}\"ripgrep\"''${NC} to ''${C_HIGHLIGHT}core.nix''${NC} and run ''${C_PRIMARY}manx rebuild''${NC}"
                  [ "''$NH_VAL" == "✗" ] && echo -e "    ''${C_MUTED}•''${NC} ''${C_WHITE}nh missing''${NC}       ''${C_MUTED}❯''${NC} Add ''${C_GOLD}\"nh\"''${NC} to ''${C_HIGHLIGHT}core.nix''${NC} and run ''${C_PRIMARY}manx rebuild''${NC}"
                  [ "''$FZF_VAL" == "✗" ] && echo -e "    ''${C_MUTED}•''${NC} ''${C_WHITE}fzf missing''${NC}      ''${C_MUTED}❯''${NC} Add ''${C_GOLD}\"fzf\"''${NC} to ''${C_HIGHLIGHT}core.nix''${NC} and run ''${C_PRIMARY}manx rebuild''${NC}"
                  [ "''$GIT_VAL" == "✗" ] && echo -e "    ''${C_MUTED}•''${NC} ''${C_WHITE}git missing''${NC}      ''${C_MUTED}❯''${NC} Add ''${C_GOLD}\"git\"''${NC} to ''${C_HIGHLIGHT}core.nix''${NC} and run ''${C_PRIMARY}manx rebuild''${NC}"
                  [ "''$OLLAMA_VAL" == "✗" ] && echo -e "    ''${C_MUTED}•''${NC} ''${C_WHITE}Ollama offline''${NC}   ''${C_MUTED}❯''${NC} Run ''${C_PRIMARY}sudo systemctl start ollama''${NC} in terminal"
                  [ "''$TOKEN_VAL" == "✗" ] && echo -e "    ''${C_MUTED}•''${NC} ''${C_WHITE}Token missing''${NC}    ''${C_MUTED}❯''${NC} Run ''${C_PRIMARY}manx aider''${NC} and paste your personal PAT"
              fi
              echo ""
          )
          ;;

        history) nixos-rebuild list-generations ;;
        rollback) log "Restoring system to previous successful state..."; sudo nixos-rebuild switch --flake .#"$HOSTNAME" --rollback ;;

        screensaver)
          BRAND_DIR="$HOME/.config/omarchy/branding"
          mkdir -p "''$BRAND_DIR"
          shift
          case "''${1:-}" in
            ascii)
              info "Opening ASCII editor. Save and exit to apply changes."
              $EDITOR "''$BRAND_DIR/screensaver.txt"
              rm -f "''$BRAND_DIR/logo.png" 2>/dev/null || true
              success "ASCII art updated. Launching preview..."
              pkill -f 'alacritty --class manx-screensaver' || true
              "$HOME/.local/bin/manx-screensaver" --force
              ;;
            image)
              IMG_PATH="''${2:-}"
              if [ -n "''$IMG_PATH" ] && [ -f "''$IMG_PATH" ]; then
                  log "Processing branding image..."; cp "''$IMG_PATH" "''$BRAND_DIR/logo.png"
                  rm -f "''$BRAND_DIR/screensaver.txt" 2>/dev/null || true
                  success "Branding image updated. Launching preview..."
                  pkill -f 'alacritty --class manx-screensaver' || true
                  "$HOME/.local/bin/manx-screensaver" --force
              else error "Please provide a valid image path. Usage: manx screensaver image <path>"; fi
              ;;
            toggle)
              TOGGLE_FILE="$HOME/.local/state/omarchy/toggles/screensaver-off"
              mkdir -p "$(dirname "''$TOGGLE_FILE")"
              if [ -f "''$TOGGLE_FILE" ]; then rm "''$TOGGLE_FILE"; success "Screensaver ENABLED."; else touch "''$TOGGLE_FILE"; info "Screensaver DISABLED."; fi
              ;;
            reset) log "Resetting branding to system defaults..."; rm -rf "''$BRAND_DIR"; success "Screensaver branding reset." ;;
            *)
              echo -e "  ''${C_SECONDARY}Usage:''${NC} ''${C_WHITE}manx screensaver''${NC} ''${C_GOLD}<action>''${NC}"
              echo -e ""
              echo -e "    ''${C_WHITE}ascii''${NC}      ''${C_MUTED}❯''${NC} Edit your custom ASCII art text"
              echo -e "    ''${C_WHITE}image''${NC}      ''${C_MUTED}❯''${NC} Set an image to be converted to ASCII"
              echo -e "    ''${C_WHITE}toggle''${NC}     ''${C_MUTED}❯''${NC} Master switch for the screensaver"
              echo -e "    ''${C_WHITE}reset''${NC}      ''${C_MUTED}❯''${NC} Restore default MANX Silicon branding"
              echo -e ""
              ;;
          esac
          ;;

        vivado)
          log "Entering AMD Vivado design environment..."
          if command -v xhost &>/dev/null; then xhost +local: &> /dev/null || true; fi
          if ! distrobox list | grep -q "manx-vivado"; then
              info "Vivado environment not found. Creating it..."; distrobox create --name manx-vivado --image ubuntu:2204 --yes || error "Failed to create container."
              success "Environment created! Use 'manx vivado' to enter."
          else
              mkdir -p "$HOME/.local/share/icons/xilinx"
              distrobox enter manx-vivado -- bash -c "cp -f /tools/Xilinx/$VIVADO_VERSION/Vivado/doc/images/vivado_logo.png \$HOME/.local/share/icons/xilinx/vivado.png 2>/dev/null || true; cp -f /tools/Xilinx/ide/electron-app/lnx64/resources/app/resources/icons/vitis-logo-latest.png \$HOME/.local/share/icons/xilinx/vitis.png 2>/dev/null || true" &>/dev/null || true
              log "Entering container. Type 'exit' to return."
              export _JAVA_AWT_WM_NONREPARENTING=1; distrobox enter manx-vivado
          fi
          ;;

        webui) log "Launching Professional AI Interface (Open-WebUI)..."; if ! curl -s http://127.0.0.1:8081 &>/dev/null; then info "Service is waking up... please wait a few seconds."; fi; xdg-open "http://localhost:8081" &>/dev/null & ;;
        routine|tracker) log "Starting MANX Self-Improvement & Daily Routine Tracker..."; TRACKER_DIR="$CONFIG_DIR/modules/system/tracker"; mkdir -p "$HOME/daily-routine-data"; if ! curl -s "http://localhost:8090" &>/dev/null; then python3 "''$TRACKER_DIR/server.py" &>/dev/null & sleep 0.8; fi; xdg-open "http://localhost:8090" &>/dev/null & success "Workspace successfully engaged." ;;
        showcase|site|web) log "Launching secure MANX OS Workstation Showcase website..."; WEBSITE_DIR="$HOME/website"; if ! curl -s "http://localhost:8050" &>/dev/null; then cd "''$WEBSITE_DIR" && python3 -m http.server 8050 &>/dev/null & sleep 0.8; fi; xdg-open "http://localhost:8050" &>/dev/null & success "Showcase site interface engaged." ;;
        *) error "Unknown command: $1. Type 'manx' for help." ;;
      esac
    '';
  };

  # Custom Manual Page
  man-page = pkgs.runCommand "manx-man" { } ''
        mkdir -p $out/share/man/man1
        cat <<EOF > $out/share/man/man1/manx.1
    .TH MANX 1 "May 2026" "v1.3" "MANX OS System Manual"
    .SH NAME
    manx \- Advanced NixOS Management Utility & AI Workspace Orchestrator
    .SH SYNOPSIS
    .B manx
    [\fIcommand\fR] [\fIarguments...\fR]
    .SH DESCRIPTION
    .B manx
    is the primary systems orchestrator for the MANX Workstation environment.
    It provides unified commands for declarative package administration, state verification, technical design software, and advanced AI agents.
    .SH COMMANDS
    .TP
    .B rebuild
    Synchronizes active files with Nix Flakes, formats code via rfc-166 standards, validates Flake integrity, regenerates Open-WebUI API connections, and applies system configuration. Outputs a granular package change diff report via NVD.
    .TP
    .B update
    Performs a comprehensive flake input pull and rebuilds the NixOS environment against the latest channels.
    .TP
    .B clean
    Executes a three-layer deep storage maintenance sweep (Prunes generations down to 3, runs Nix Garbage Collection, and optimizes the Nix store by hard-linking identical packages).
    .TP
    .B check
    Runs static auditing checks on the local Flake configuration using nix flake check to catch bugs before building.
    .TP
    .B doctor
    Launches the interactive borderless system diagnostic suite, showing visual indicators for NixOS, core package status, services (Ollama/WebUI), and secure keypaths.
    .TP
    .B bootstrap
    Initializes blank Btrfs subvolumes for stateless rollbacks, generates machine-id mappings, and checks sops secrets decryption keypaths.
    .TP
    .B aider
    Launches the High-Fidelity Engineering Coding Agent in the current directory. Supports selecting local Ollama models (Qwen2.5-Coder) or native cloud models (Claude 3.5 Sonnet, Gemini Pro, Llama-3.3-70B, Cohere Command-R+) with automatic workspace file indexing.
    .TP
    .B agent [\fI-y\fR]
    Launches the Local System Execution Agent (Open-Interpreter). Supports interactive approval mode by default. Pass the \fB-y\fR flag to run in fully autonomous, hands-free mode.
    .TP
    .B webui
    Spins up the professional local web interface (Open-WebUI) mapping all offline Ollama engines and online cloud endpoints (GitHub Inference + Google Gemini) simultaneously.
    .TP
    .B routine
    Engages the Silicon self-improvement routine logging dashboard on a secure local port.
    .TP
    .B showcase
    Launches the static workstation design and engineering portfolio local showcase.
    .TP
    .B screensaver [\fIascii|image|toggle|reset\fR]
    Manages ASCII/Image art screensaver layouts. Toggle enables or disables workstation screensaver protocols.
    .TP
    .B vivado
    Enters the high-performance containerized AMD Vivado/Vitis design environment.
    .SH AI CONFIGURATION & SECURITY
    All secure key files must be created in the local home folder:
    .IP \(bu 2
    GitHub Models Token: \fB~/.config/manx/github_token\fR
    .IP \(bu 2
    Gemini AI Studio Token: \fB~/.config/manx/gemini_token\fR
    .IP \(bu 2
    Anthropic API Token: \fB~/.config/manx/anthropic_token\fR
    .PP
    Running \fBmanx rebuild\fR automatically synchronizes these tokens into the Open-WebUI service environment and reloads the server instantly.
    .SH AUTHOR
    MANX Engineering Workstation Group.
    EOF
  '';
in
{
  environment.systemPackages = [
    manx-script
    pkgs.nixfmt
    man-page
  ];

  documentation.man.enable = true;
}
