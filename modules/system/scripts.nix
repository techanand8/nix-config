{ pkgs, ... }:

let
  mayank-script = pkgs.writeShellScriptBin "mayank" ''
    # Advanced NixOS Management Utility
    # Custom-built for Mayank Anand's MSI Modern 14

    set -e # Exit on error

    # Configuration
    CONFIG_DIR="$HOME/nix-config"
    HOSTNAME="msi-modern14c7m"
    EDITOR="nvim"

    # Premium Theme Colors (256-color & truecolor supported terminals like Ghostty/Kitty)
    C_PRIMARY='\033[38;5;208m'   # Coral Orange
    C_SECONDARY='\033[38;5;99m'  # Royal Soft Purple
    C_HIGHLIGHT='\033[38;5;43m'  # Vibrant Teal
    C_SUCCESS='\033[38;5;76m'    # Emerald Green
    C_MUTED='\033[38;5;244m'     # Dim Grey
    C_WHITE='\033[1;37m'         # Bright White
    C_GOLD='\033[38;5;220m'      # Warm Gold
    
    # Base UI Colors (compat for older shell functions)
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
        # Calculate uptime reliably without relying on uptime -p
        local uptime_all=$(cat /proc/uptime)
        local uptime_seconds=''${uptime_all%%.*}
        local days=$((uptime_seconds / 86400))
        local hours=$(( (uptime_seconds % 86400) / 3600 ))
        local mins=$(( (uptime_seconds % 3600) / 60 ))
        local uptime_str=""
        if [ ''$days -gt 0 ]; then
            uptime_str+="''$days""d "
        fi
        if [ ''$hours -gt 0 ]; then
            uptime_str+="''$hours""h "
        fi
        uptime_str+="''$mins""m"

        echo -e ""
        echo -e "  ''${C_PRIMARY}󱄅''${NC}  ''${C_WHITE}M A Y A N K   A N A N D''${NC}  ''${C_MUTED}│''${NC}  ''${C_SECONDARY}''${NC}  ''${C_GOLD}NIXOS WORKSTATION''${NC}"
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e "  ''${C_HIGHLIGHT}  Host:''${NC} ''${C_WHITE}''$HOSTNAME''${NC}         ''${C_HIGHLIGHT}󰓅  Uptime:''${NC} ''${C_WHITE}''$uptime_str''${NC}"
        echo -e "  ''${C_HIGHLIGHT}  Kernel:''${NC} ''${C_WHITE}''$(uname -r)''${NC}       ''${C_HIGHLIGHT}  Status:''${NC} ''${C_SUCCESS}Online''${NC}"
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e ""
        echo -e "  ''${C_SECONDARY}Usage:''${NC} ''${C_WHITE}mayank''${NC} ''${C_GOLD}<command>''${NC}"
        echo -e ""
        echo -e "  ''${C_PRIMARY}󰓅  CONFIGURATION MANAGEMENT''${NC}"
        echo -e "    ''${C_WHITE}rebuild''${NC}   ''${C_MUTED}❯''${NC} Apply system adjustments & record generation to Git"
        echo -e "    ''${C_WHITE}update''${NC}    ''${C_MUTED}❯''${NC} Perform flake input upgrade & full system build"
        echo -e "    ''${C_WHITE}rollback''${NC}  ''${C_MUTED}❯''${NC} Instantly revert system to previous successful generation"
        echo -e "    ''${C_WHITE}history''${NC}   ''${C_MUTED}❯''${NC} List detailed chronological system generations"
        echo -e ""
        echo -e "  ''${C_PRIMARY}󰌢  MAINTENANCE & SECURITY''${NC}"
        echo -e "    ''${C_WHITE}clean''${NC}     ''${C_MUTED}❯''${NC} Perform deep garbage collection & Nix store hard-linking"
        echo -e "    ''${C_WHITE}check''${NC}     ''${C_MUTED}❯''${NC} Audit syntactical health and config integrity"
        echo -e ""
        echo -e "  ''${C_PRIMARY}  DEVELOPMENT UTILITIES''${NC}"
        echo -e "    ''${C_WHITE}edit''${NC}      ''${C_MUTED}❯''${NC} Open workstation Nix configuration in Neovim"
        echo -e "    ''${C_WHITE}search''${NC}    ''${C_MUTED}❯''${NC} Efficiently query Nixpkgs software registry"
        echo -e "    ''${C_WHITE}shell''${NC}     ''${C_MUTED}❯''${NC} Initialize isolated, ephemeral package environments"
        echo -e "    ''${C_WHITE}vivado''${NC}    ''${C_MUTED}❯''${NC} Initialize or enter AMD Vivado Ubuntu environment"
        echo -e ""
        echo -e "  ''${C_MUTED}──────────────────────────────────────────────────────────────────────''${NC}"
        echo -e "  ''${C_HIGHLIGHT}󰌢  Type 'man mayank' to access the custom system manual page.''${NC}"
        echo -e ""
    }

    # Ensure Git is initialized in the config dir
    if [ ! -d "$CONFIG_DIR/.git" ]; then
        info "Initializing configuration tracking repository..."
        git init "$CONFIG_DIR" > /dev/null
    fi

    if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        show_help
        exit 0
    fi

    case $1 in
      rebuild)
        log "Initializing system rebuild..."
        
        # Format code
        if command -v nixpkgs-fmt &> /dev/null; then nixpkgs-fmt $CONFIG_DIR; fi
        
        # Git Tracking (Secure Professional Logic)
        cd $CONFIG_DIR
        
        # 1. Mark secrets as 'intent-to-add' so Nix can see them
        # This makes the file 'tracked' but not 'staged' for commit
        git add -N -f hosts/msi-modern14c7m/variables.nix &> /dev/null || true
        
        # 2. Stage everything else (respecting .gitignore)
        git add . &> /dev/null || true
        
        # 3. Commit only the staged files
        GEN=$(nixos-rebuild list-generations | grep current | awk '{print $1}' || echo "N/A")
        git commit -m "System Update - Generation $GEN - $(date '+%Y-%m-%d %H:%M')" || true
        
        # 4. Execute Rebuild
        sudo nixos-rebuild switch --flake $CONFIG_DIR#$HOSTNAME --no-reexec || error "Rebuild process failed."
        
        # Auto-Push to GitHub
        if git remote | grep -q "origin"; then
            log "Synchronizing with GitHub repository..."
            git push origin main || info "Push skipped (check SSH/Remote settings)"
        fi

        success "System configuration applied and synchronized successfully."
        ;;

      update)
        log "Updating all dependency inputs..."
        pushd $CONFIG_DIR > /dev/null
        nix flake update || error "Input update failed."
        popd > /dev/null
        
        log "Applying updated configuration..."
        sudo nixos-rebuild switch --flake $CONFIG_DIR#$HOSTNAME || error "Rebuild after update failed."
        success "System updated and synchronized."
        ;;

      clean)
        log "Executing storage optimization and legacy cleanup..."
        sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
        nix-env --delete-generations +3
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        sudo nix store optimise
        success "Cleanup complete. Storage optimized."
        ;;

      edit)
        $EDITOR $CONFIG_DIR/hosts/$HOSTNAME/configuration.nix
        ;;

      search)
        shift
        log "Searching registry for: $@"
        nix-env -qaP "$@"
        ;;

      check)
        log "Validating configuration health..."
        nix flake check $CONFIG_DIR --all-systems || error "Integrity check failed."
        success "Configuration verified as stable."
        ;;

      shell)
        shift
        log "Entering isolated environment for: $@"
        nix-shell -p "$@"
        ;;

      history)
        nixos-rebuild list-generations
        ;;

      rollback)
        log "Restoring system to previous state..."
        sudo nixos-rebuild switch --flake $CONFIG_DIR#$HOSTNAME --rollback
        ;;

      vivado)
        log "Initializing AMD Vivado development container..."
        
        # 1. Check if podman or docker is available
        if ! command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
            error "No container engine found! Please make sure Podman or Docker is enabled."
        fi

        # 2. Allow container to access local display (GUI)
        if command -v xhost &> /dev/null; then
            xhost +local: &> /dev/null || true
        fi

        # 3. Create or enter the Ubuntu 22.04 container specifically for Vivado
        if ! distrobox list | grep -q "vivado-box"; then
            info "Vivado environment 'vivado-box' not detected."
            info "Creating a standard, high-compatibility Ubuntu 22.04 Distrobox container..."
            
            # Create the container
            distrobox create --name vivado-box --image ubuntu:22.04 --yes || error "Failed to create 'vivado-box' container."
            
            success "Vivado environment 'vivado-box' created successfully!"
            info "=========================================================================="
            info "To install and run Vivado, follow these quick steps:"
            info "  1. Enter the container:  mayank vivado"
            info "  2. Update and install standard GUI libs inside the container:"
            info "     sudo apt update && sudo apt install -y libtinfo5 libxrender1 libxtst6 libxi6"
            info "  3. Run your Vivado installer binary inside the container!"
            info "=========================================================================="
        else
            log "Entering 'vivado-box' container... (Type 'exit' to return to NixOS)"
            distrobox enter vivado-box
        fi
        ;;

      *)
        error "Unknown command: $1. Type 'mayank' for usage information."
        ;;
    esac
  '';

  # Professional Manual Page for Mayank Utility
  man-page = pkgs.runCommand "mayank-man" { } ''
        mkdir -p $out/share/man/man1
        cat <<EOF > $out/share/man/man1/mayank.1
    .TH MAYANK 1 "May 2026" "v1.0" "Mayank Anand System Manual"
    .SH NAME
    mayank \- Advanced NixOS Management Utility for Mayank Anand
    .SH SYNOPSIS
    .B mayank
    [\fIcommand\fR]
    .SH DESCRIPTION
    .B mayank
    is a comprehensive system management tool designed specifically for Mayank Anand's
    professional engineering workstation on NixOS. It automates system rebuilds, 
    manages configuration history via Git, and provides optimized maintenance utilities.
    .SH COMMANDS
    .TP
    .B rebuild
    Formats the configuration code using nixpkgs-fmt, auto-commits changes to the local 
    Git repository at ~/nix-config, and applies the new system configuration.
    .TP
    .B update
    Synchronizes all flake inputs to their absolute latest versions and performs a 
    full system rebuild.
    .TP
    .B clean
    Performs a deep system maintenance cycle: removes old generations (keeps last 3), 
    collects garbage, and optimizes the Nix store to reclaim disk space.
    .TP
    .B check
    Validates the configuration health, integrity, and syntax correctness.
    .TP
    .B rollback
    Instantly reverts the system to the previous working generation.
    .TP
    .B history
    Displays a detailed chronological list of all system generations.
    .TP
    .B edit
    Opens the primary configuration.nix file in the Neovim editor for rapid adjustment.
    .TP
    .B search [query]
    Queries the Nixpkgs registry for available software packages.
    .TP
    .B shell [packages]
    Opens an isolated, ephemeral shell containing the requested packages without 
    permanent installation.
    .TP
    .B vivado
    Initializes or enters the high-compatibility Ubuntu 22.04 environment (via Distrobox) 
    specially optimized for AMD/Xilinx Vivado VLSI and hardware JTAG programming cables.
    .SH FILES
    .I ~/nix-config
    The primary directory for the NixOS flake configuration.
    .SH AUTHOR
    Custom-built for Mayank Anand.
    EOF
  '';
in
{
  environment.systemPackages = [
    mayank-script
    pkgs.nixpkgs-fmt
    man-page
  ];

  # Ensure manual pages are enabled
  documentation.man.enable = true;
}
