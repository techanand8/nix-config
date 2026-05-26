{ pkgs, vars, ... }:

let
  manx-script = pkgs.writeShellScriptBin "manx" ''
        # Advanced NixOS Management Utility
        # Custom-built for the MANX Engineering Workstation

        set -e # Exit on error

        # --- CONFIGURATION ---
        CONFIG_DIR="$HOME/nix-config"
        export FLAKE="$CONFIG_DIR"
        export NH_FLAKE="$CONFIG_DIR"
        export NIXPKGS_ALLOW_UNFREE=1

        # Smart Host Detection: Normalize hostname to match Flake targets (MANX or LAPTOP)
        RAW_HOSTNAME=$(hostname)
        UPPER_HOST=$(echo "$RAW_HOSTNAME" | tr '[:lower:]' '[:upper:]')

        if [[ "$UPPER_HOST" == *LAPTOP* ]]; then
            HOSTNAME="LAPTOP"
            HOST_DIR="laptop"
        elif [[ "$UPPER_HOST" == *MANX* ]]; then
            HOSTNAME="MANX"
            HOST_DIR="manx"
        else
            # Fallback to MANX as default workstation
            HOSTNAME="MANX"
            HOST_DIR="manx"
        fi

        # UI Branding (Always MANX for the workstation family)
        BRAND_NAME="MANX"

        EDITOR="nvim"
        VIVADO_VERSION="${vars.vivadoVersion}"

        # --- COLOR PALETTE (Optimized for Ghostty/Kitty) ---
        C_PRIMARY='\033[38;5;208m'   # Coral Orange
        C_SECONDARY='\033[38;5;99m'  # Royal Soft Purple
        C_HIGHLIGHT='\033[38;5;43m'  # Vibrant Teal
        C_SUCCESS='\033[38;5;76m'    # Emerald Green
        C_MUTED='\033[38;5;244m'     # Dim Grey
        C_WHITE='\033[1;37m'         # Bright White
        C_GOLD='\033[38;5;220m'      # Warm Gold

        # Base UI Colors (Compat for legacy shell functions)
        GREEN='\033[1;32m'
        BLUE='\033[1;34m'
        YELLOW='\033[1;33m'
        RED='\033[1;31m'
        MAGENTA='\033[1;35m'
        CYAN='\033[1;36m'
        NC='\033[0m'

        function log() { echo -e "''${C_SECONDARY}  [SYSTEM]''${NC} $1"; }
        function error() { echo -e "''${RED}󰅚  [ERROR]''${NC} $1"; exit 1; }
        function success() { echo -e "''${C_SUCCESS}󰄬  [SUCCESS]''${NC} $1"; }
        function info() { echo -e "''${C_HIGHLIGHT}󰌢  [INFO]''${NC} $1"; }

        # Help Menu Function
        function show_help() {
            # Calculate uptime reliably
            local uptime_all=$(cat /proc/uptime)
            local uptime_seconds=''${uptime_all%%.*}
            local days=$((uptime_seconds / 86400))
            local hours=$(( (uptime_seconds % 86400) / 3600 ))
            local mins=$(( (uptime_seconds % 3600) / 60 ))
            local uptime_str=""
            if [ ''$days -gt 0 ]; then uptime_str+="''$days""d "; fi
            if [ ''$hours -gt 0 ]; then uptime_str+="''$hours""h "; fi
            uptime_str+="''$mins""m"

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

        # Initialize Git tracking if it's missing
        if [ ! -d "$CONFIG_DIR/.git" ]; then
            info "Initializing configuration tracking repository..."
            git init "$CONFIG_DIR" > /dev/null
        fi

        if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
            show_help
            exit 0
        fi

        # Jump to the config directory for all operations
        cd "$CONFIG_DIR"

        case $1 in
          rebuild)
            log "Executing system synchronization..."

            # --- SECURITY SHIELD: Automated Cleanup Trap ---
            # This ensures that even if you Ctrl+C the script, your secrets are UNSTAGED immediately.
            cleanup_secrets() {
                git reset -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true
            }
            trap cleanup_secrets EXIT SIGINT SIGTERM

            # 0. Create pre-rebuild Btrfs snapshots for safety
            if command -v snapper &> /dev/null; then            log "Creating pre-rebuild snapshots (Time Machine)..."
                # Root is excluded because it is stateless and wiped on every boot
                sudo snapper -c home create --description "Pre-rebuild home snapshot" || true
            fi

            # 1. Enforce code style standards (RFC-166) BEFORE staging
            nix fmt
            
            # 2. Stage changes so Nix Flakes can see the configuration
            # We forcefully stage private files so Nix can see them for the build.
            # They will be UNSTAGED before the commit step for absolute privacy.
            git add -f -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true
            git add . &> /dev/null || true
            
            # 3. Validate configuration integrity before applying
            log "Validating configuration health..."
            CHECK_ERR=$(mktemp)
            if ! nix flake check . 2>"$CHECK_ERR"; then
                grep -v -E "incompatible systems|all-systems" "$CHECK_ERR" >&2 || true
                rm -f "$CHECK_ERR"
                # Unstage on failure for safety
                cleanup_secrets
                error "Configuration audit failed. Please resolve errors before rebuilding."
            else
                grep -v -E "incompatible systems|all-systems" "$CHECK_ERR" >&2 || true
                rm -f "$CHECK_ERR"
            fi
            
            # 4. Capture current system state for delta reporting
            OLD_GEN=$(readlink -f /nix/var/nix/profiles/system)
            
            # 5. Apply system configuration via NH
            log "Applying system updates..."
            if ! nh os switch . --hostname $HOSTNAME -- --accept-flake-config; then
                # Unstage on failure for safety
                cleanup_secrets
                error "System rebuild failed."
            fi
            
            # MANDATORY SECURITY: Unstage secrets immediately after a successful build
            cleanup_secrets
            
            # 6. SDDM Maintenance: Clear persistent cache to force theme update
            if [ -d "/persist/var/lib/sddm" ]; then
                log "Clearing SDDM persistent cache for theme synchronization..."
                sudo rm -rf /persist/var/lib/sddm/* &> /dev/null || true
            fi
            
            # 7. Generate package change report
            NEW_GEN=$(readlink -f /nix/var/nix/profiles/system)
            echo -e "\n''${C_HIGHLIGHT}  Package Changes:''${NC}"
            nvd diff "$OLD_GEN" "$NEW_GEN"
            
            # Double-check secrets are removed from index before checking commit status
            cleanup_secrets
            
            if git status --porcelain | grep -q '^[ MADRCU]'; then
                log "Recording system state to Git history..."
                echo -e "\n''${C_MUTED}Change Summary:''${NC}"
                git diff --stat --staged
                git commit -m "System Update: $(date '+%Y-%m-%d %H:%M')" &> /dev/null || true
            fi

            # 8. Synchronize with remote repository (Optional)
            if git remote | grep -q "origin"; then
                log "Synchronizing configuration with GitHub..."
                # Capture stdout and stderr to handle feedback accurately
                PUSH_OUTPUT=$(git push origin main 2>&1) || true
                if [ -z "$PUSH_OUTPUT" ] || echo "$PUSH_OUTPUT" | grep -q "Everything up-to-date"; then
                    info "GitHub is already up-to-date (no new changes to push)."
                elif echo "$PUSH_OUTPUT" | grep -q -E "To |Update|master ->|main ->"; then
                    success "GitHub synchronization complete. All changes are backed up!"
                else
                    info "GitHub synchronization completed or skipped."
                    echo "$PUSH_OUTPUT" | sed 's/^/  /' # Indent output for cleaner display
                fi
            fi

            # 9. Push to binary cache (Cachix - Modern Cloud Backup)
            if [ ! -z "${vars.cachixName}" ] && [ "${vars.cachixName}" != "your-cachix-subdomain" ]; then
                log "Pushing system build to Cachix (${vars.cachixName})..."
                if cachix push ${vars.cachixName} "$NEW_GEN" &> /dev/null; then
                    success "Cachix synchronization successful!"
                else
                    info "Cachix push failed (Check if you are logged in: 'cachix authtoken <token>')"
                fi
            fi

            success "System configuration applied successfully."
            ;;

          update)
            log "Updating system inputs and dependencies..."
            nh os switch . --update --hostname $HOSTNAME || error "System update failed."
            success "System updated and synchronized."
            ;;

          clean)
            log "Performing deep system maintenance..."
            
            # LAYER 1: Generation Pruning
            log "Pruning legacy generations (Keeping last 3)..."
            nh clean all --keep 3
            
            # LAYER 2: Garbage Collection
            log "Executing garbage collection cycle..."
            sudo nix-collect-garbage -d
            nix-collect-garbage -d
            
            # LAYER 3: Store Optimization
            log "Optimizing Nix store (Hard-linking duplicates)..."
            sudo nix-store --optimise
            
            success "System maintenance complete. Storage optimized."
            ;;

          bootstrap)
            log "Initializing Stateless Btrfs & SOPS Environment Bootstrapping..."
            
            # 1. Btrfs subvolume layout setup
            if findmnt -n -o FSTYPE / 2>/dev/null | grep -q "btrfs" || findmnt -n -o FSTYPE /persist 2>/dev/null | grep -q "btrfs"; then
                log "Btrfs file system verified."
                
                # Find physical Btrfs device
                DEV_PATH=$(findmnt -n -o SOURCE /persist 2>/dev/null || findmnt -n -o SOURCE / 2>/dev/null || true)
                if [ -n "$DEV_PATH" ]; then
                    log "Discovered Btrfs device: $DEV_PATH"
                    
                    # Setup Mount and Verify Subvolume Layout
                    mkdir -p /tmp/btrfs-root
                    if sudo mount -t btrfs -o subvolid=5 "$DEV_PATH" /tmp/btrfs-root &>/dev/null; then
                        log "Mounted Btrfs root subvolid=5 successfully."
                        
                        if [ ! -d "/tmp/btrfs-root/blank" ]; then
                            info "Stateless rollback snapshot '/blank' not found. Creating it..."
                            sudo btrfs subvolume create /tmp/btrfs-root/blank
                            success "Pristine '/blank' subvolume created."
                        else
                            success "Pristine '/blank' subvolume already exists."
                        fi
                        
                        sudo umount /tmp/btrfs-root
                        rm -rf /tmp/btrfs-root
                    else
                        info "Unable to mount Btrfs subvolid=5 directly. Ensure you run this with sudo permissions."
                    fi
                fi
            else
                info "Root/Persist is not formatted as Btrfs. Skipping subvolume checks."
            fi

            # 2. SOPS age keyfile directory setup
            KEY_DIR="/persist/var/lib/sops-nix"
            if [ -d "/persist" ]; then
                log "Verifying SOPS decryption keypaths..."
                sudo mkdir -p "$KEY_DIR"
                sudo chmod 0755 /persist/var/lib 2>/dev/null || true
                sudo chmod 0700 "$KEY_DIR" 2>/dev/null || true
                
                if [ ! -f "$KEY_DIR/key.txt" ]; then
                    info "SOPS age key '$KEY_DIR/key.txt' is missing."
                    info "Generate using: 'age-keygen -o $KEY_DIR/key.txt'"
                else
                    success "SOPS decryption age key is present."
                fi
            else
                info "/persist directory not found. Skipping secrets keypath checks."
            fi
            
            success "Bootstrap process completed."
            ;;

          word)
            log "Launching Professional Documentation Suite (OnlyOffice)..."
            onlyoffice-desktopeditors &> /dev/null &
            disown
            ;;

          writer)
            log "Initializing Technical Documentation Engine (LibreOffice Writer)..."
            lowriter &> /dev/null &
            disown
            ;;

          calc)
            log "Opening Engineering Analysis Environment (LibreOffice Calc)..."
            localc &> /dev/null &
            disown
            ;;

          impress)
            log "Launching Silicon Presentation Suite (LibreOffice Impress)..."
            loimpress &> /dev/null &
            disown
            ;;

          draw)
            log "Initializing Schematic & Flow Diagram Engine (LibreOffice Draw)..."
            lodraw &> /dev/null &
            disown
            ;;

          edit)
            # 1. Direct Edit (if filename provided)
            if [ ! -z "$2" ]; then
                if [ -f "$2" ]; then
                    $EDITOR "$2"
                else
                    error "File not found: $2"
                fi
            # 2. Interactive Fuzzy Find (if no filename provided)
            else
                if command -v fzf &> /dev/null; then
                    log "Launching interactive configuration navigator..."
                    # Find all .nix and .yaml files, excluding hidden ones and git dirs
                    FILE=$(find . -maxdepth 4 \( -name "*.nix" -o -name "*.yaml" \) -not -path '*/.*' | fzf --preview "bat --color=always --style=numbers {}" --height 80% --layout=reverse --border --prompt="󱄅 Edit Config ❯ ")
                    if [ ! -z "$FILE" ]; then
                        $EDITOR "$FILE"
                    else
                        info "No file selected. Exiting."
                    fi
                else
                    # Fallback to default if fzf is missing
                    $EDITOR hosts/$HOST_DIR/configuration.nix
                fi
            fi
            ;;

          search)
            shift
            log "Querying Nixpkgs registry for: $@"
            nh search "$@"
            ;;

          check)
            log "Auditing configuration health..."

            # --- SECURITY SHIELD: Automated Cleanup Trap ---
            # This ensures that even if you Ctrl+C the script, your secrets are UNSTAGED immediately.
            cleanup_secrets() {
                git reset -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true
            }
            trap cleanup_secrets EXIT SIGINT SIGTERM

            # Stage changes so Nix Flakes can see the configuration
            git add -f -- hosts/manx/variables.nix hosts/laptop/variables.nix secrets/secrets.yaml &> /dev/null || true

            CHECK_ERR=$(mktemp)
            if ! nix flake check . 2>"$CHECK_ERR"; then
                grep -v -E "incompatible systems|all-systems" "$CHECK_ERR" >&2 || true
                rm -f "$CHECK_ERR"
                # Unstage on failure for safety
                cleanup_secrets
                error "Configuration audit failed."
            else
                grep -v -E "incompatible systems|all-systems" "$CHECK_ERR" >&2 || true
                rm -f "$CHECK_ERR"
                success "Configuration verified."
            fi
            ;;

          shell)
            shift
            log "Entering shell for: $@"
            nix-shell -p "$@"
            ;;

          aider)
            log "Launching High-Fidelity Engineering Agent (DeepSeek-Coder:6.7b Stable)..."
            # Verify Ollama service is active
            if ! curl -s http://127.0.0.1:11434 &>/dev/null; then
                error "Ollama service is not running! Start it via 'sudo systemctl start ollama'."
            fi
            # Check if the model is locally pulled; download with progress if missing
            if ! ollama list 2>/dev/null | grep -q "deepseek-coder:6.7b"; then
                info "DeepSeek-Coder:6.7b not found locally. Downloading model (visible progress)..."
                ollama pull deepseek-coder:6.7b
            fi
            export OLLAMA_API_BASE="http://127.0.0.1:11434"
            # Professional Aider Flags: 
            # --no-browser: Keeps the focus in the terminal
            # --watch-files: Automatically detects changes you make manually
            aider --model ollama/deepseek-coder:6.7b --no-browser --watch-files "$@"
            ;;

          agent)
            log "Launching Elite Personal Task Agent (Open-Interpreter + Llama-3.1)..."
            
            # Verify Ollama is alive
            if ! curl -s http://127.0.0.1:11434 &>/dev/null; then
                error "Ollama service is not running! Start it via 'sudo systemctl start ollama'."
            fi

            case $1 in
              update)
                shift
                log "Self-healing Agent Environment..."
                nix-shell -p python312 pipx gcc rustc cargo --run "pipx install --python python3.12 --force open-interpreter && pipx runpip open-interpreter install 'setuptools<70'"
                # Re-apply the library fix
                LIB_PATH=$(find /nix/store -maxdepth 3 -name "libstdc++.so.6" | grep "gcc-15" | head -n 1 | xargs dirname)
                mv $HOME/.local/bin/interpreter $HOME/.local/bin/interpreter.real 2>/dev/null || true
                cat << EOF > $HOME/.local/bin/interpreter
    #!/usr/bin/env bash
    export LD_LIBRARY_PATH="$LIB_PATH:\$LD_LIBRARY_PATH"
    exec $HOME/.local/bin/interpreter.real "\$@"
    EOF
                chmod +x $HOME/.local/bin/interpreter
                success "Agent brain updated and patched!"
                ;;
              
              *)
                # Run the Native Agent (Connected to Local Ollama)
                log "Agent is active. Type 'exit' to return to MANX shell."
                interpreter --local --model llama3.1 --api_base http://127.0.0.1:11434/v1 "$@"
                ;;
            esac
            ;;

          history)
            nixos-rebuild list-generations
            ;;

          rollback)
            log "Restoring system to previous successful state..."
            sudo nixos-rebuild switch --flake .#$HOSTNAME --rollback
            ;;

          screensaver)
            BRAND_DIR="$HOME/.config/omarchy/branding"
            mkdir -p "$BRAND_DIR"
            
            shift
            case $1 in
              ascii)
                info "Opening ASCII editor. Save and exit to apply changes."
                $EDITOR "$BRAND_DIR/screensaver.txt"
                # Clean up logo if text is being used
                rm -f "$BRAND_DIR/logo.png" 2>/dev/null || true
                success "ASCII art updated. Launching preview..."
                pkill -f 'alacritty --class manx-screensaver' || true
                "$HOME/.local/bin/manx-screensaver" --force
                ;;
              
              image)
                IMG_PATH="$2"
                if [ -z "$IMG_PATH" ] || [ ! -f "$IMG_PATH" ]; then
                    error "Please provide a valid image path. Usage: manx screensaver image <path>"
                fi
                
                log "Processing branding image..."
                cp "$IMG_PATH" "$BRAND_DIR/logo.png"
                # Clean up text if image is being used
                rm -f "$BRAND_DIR/screensaver.txt" 2>/dev/null || true
                
                success "Branding image updated. Launching preview..."
                pkill -f 'alacritty --class manx-screensaver' || true
                "$HOME/.local/bin/manx-screensaver" --force
                ;;
              
              toggle)
                TOGGLE_FILE="$HOME/.local/state/omarchy/toggles/screensaver-off"
                mkdir -p "$(dirname "$TOGGLE_FILE")"
                if [ -f "$TOGGLE_FILE" ]; then
                    rm "$TOGGLE_FILE"
                    success "Screensaver ENABLED."
                else
                    touch "$TOGGLE_FILE"
                    info "Screensaver DISABLED."
                fi
                ;;
              
              reset)
                log "Resetting branding to system defaults..."
                rm -rf "$BRAND_DIR"
                success "Screensaver branding reset."
                ;;
                
              *)
                echo -e "  ''${C_SECONDARY}Usage:''${NC} ''${C_WHITE}manx screensaver''${NC} ''${C_GOLD}<action>''${NC}"
                echo -e ""
                echo -e "    ''${C_WHITE}ascii''${NC}   ''${C_MUTED}❯''${NC} Edit your custom ASCII art text"
                echo -e "    ''${C_WHITE}image''${NC}   ''${C_MUTED}❯''${NC} Set an image to be converted to ASCII"
                echo -e "    ''${C_WHITE}toggle''${NC}  ''${C_MUTED}❯''${NC} Master switch for the screensaver"
                echo -e "    ''${C_WHITE}reset''${NC}   ''${C_MUTED}❯''${NC} Restore default MANX Silicon branding"
                echo -e ""
                ;;
            esac
            ;;

          vivado)
            log "Entering AMD Vivado container..."
            
            if ! command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
                error "No container engine found!"
            fi

            if command -v xhost &>/dev/null; then
                xhost +local: &> /dev/null || true
            fi

            if ! distrobox list | grep -q "manx-vivado"; then
                info "Vivado environment not found. Creating it..."
                distrobox create --name manx-vivado --image ubuntu:22.04 --yes || error "Failed to create container."
                success "Environment created! Use 'manx vivado' to install."
            else
                mkdir -p $HOME/.local/share/icons/xilinx
                distrobox enter manx-vivado -- bash -c "
                    cp -f /tools/Xilinx/$VIVADO_VERSION/Vivado/doc/images/vivado_logo.png \$HOME/.local/share/icons/xilinx/vivado.png 2>/dev/null || true
                    cp -f /tools/Xilinx/ide/electron-app/lnx64/resources/app/resources/icons/vitis-logo-latest.png \$HOME/.local/share/icons/xilinx/vitis.png 2>/dev/null || true
                " &> /dev/null || true

                log "Entering container. Type 'exit' to return."
                export _JAVA_AWT_WM_NONREPARENTING=1
                distrobox enter manx-vivado
            fi
            ;;

          webui)
            log "Launching Professional AI Interface (Open-WebUI)..."
            # Verify if service is active
            if ! ${pkgs.curl}/bin/curl -s http://127.0.0.1:8081 &>/dev/null; then
                info "Service is waking up... please wait a few seconds."
            fi
            ${pkgs.xdg-utils}/bin/xdg-open "http://localhost:8081" &>/dev/null &
            ;;

          routine|tracker)
            log "Starting MANX Self-Improvement & Daily Routine Tracker..."
            
            TRACKER_DIR="$CONFIG_DIR/modules/system/tracker"
            DATA_DIR="$HOME/daily-routine-data"
            mkdir -p "$DATA_DIR"

            # Check if tracker is already running
            if ${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" "http://localhost:8090/api/data?date=2020-01-01" &>/dev/null; then
                info "Tracker backend is active. Opening dashboard..."
            else
                info "Initializing lightweight secure tracker database engine..."
                # Start Python standard library web server in background
                ${pkgs.python3}/bin/python3 "$TRACKER_DIR/server.py" &>/dev/null &
                sleep 0.8
            fi

            # Open browser
            ${pkgs.xdg-utils}/bin/xdg-open "http://localhost:8090" &>/dev/null &
            success "Routine Workspace successfully engaged."
            ;;

          showcase|site|web)
            log "Launching secure MANX OS Workstation Showcase website..."
            
            WEBSITE_DIR="$HOME/website"
            PORT=8050

            # Check if local server is already running on PORT
            if ${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT" &>/dev/null; then
                info "Showcase website server is already active. Launching interface..."
            else
                info "Initializing secure background static web server on port $PORT..."
                # Launch Python's lightweight standard HTTP server inside website directory
                cd "$WEBSITE_DIR"
                ${pkgs.python3}/bin/python3 -m http.server $PORT &>/dev/null &
                sleep 0.8
                cd "$CONFIG_DIR"
            fi

            # Open web browser securely
            ${pkgs.xdg-utils}/bin/xdg-open "http://localhost:$PORT" &>/dev/null &
            success "Showcase site interface engaged successfully!"
            ;;

          *)
            error "Unknown command: $1. Type 'manx' for help."
            ;;
        esac
  '';

  # Custom Manual Page
  man-page = pkgs.runCommand "manx-man" { } ''
        mkdir -p $out/share/man/man1
        cat <<EOF > $out/share/man/man1/manx.1
    .TH MANX 1 "May 2026" "v1.2" "MANX OS System Manual"
    .SH NAME
    manx \- Advanced NixOS Management Utility
    .SH SYNOPSIS
    .B manx
    [\fIcommand\fR]
    .SH DESCRIPTION
    .B manx
    is a professional management tool for the MANX workstation. It uses NH, NVD, and Deep Clean protocols.
    .SH COMMANDS
    .TP
    .B rebuild
    Applies the configuration with NH and shows a package diff report.
    .TP
    .B update
    Updates all inputs and performs a full rebuild.
    .TP
    .B clean
    A three-layer deep maintenance protocol for storage optimization.
    .TP
    .B word
    Launches the professional OnlyOffice documentation suite.
    .TP
    .B writer
    Technical word processor for hardware engineering documentation.
    .TP
    .B calc
    Advanced engineering analysis and spreadsheets.
    .TP
    .B impress
    Design presentation and timing diagram visualization.
    .TP
    .B draw
    Vector-based logic flows and schematic diagrams.
    .TP
    .B check
    Validates config integrity using nix flake check.
    .TP
    .B bootstrap
    Automates Btrfs pristine blank subvolume setup and SOPS age keys directories.
    .TP
    .B aider
    High-Fidelity Engineering Agent (DeepSeek-16B).
    .TP
    .B agent
    Local Execution Agent (Uses Llama-3.1 to perform system tasks).
    .TP
    .B webui
    Local Intelligence Interface (Professional Web-UI).
    .TP
    .B vivado
    Enters the high-compatibility Vivado container.
    .TP
    .B routine
    Launch the Silicon Routine & Self-Improvement Dashboard (Private database logs).
    .TP
    .B screensaver
    Manages custom branding (ASCII/Image) and the master toggle for the Omarchy-style screensaver.
    .TP
    .B showcase
    Launches the secure static Workstation Portfolio Showcase page locally.
    .SH AUTHOR
    MANX Engineering.
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
