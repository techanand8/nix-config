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

    # Colors for output
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color

    function log() { echo -e "''${BLUE}[SYSTEM]''${NC} $1"; }
    function error() { echo -e "''${RED}[ERROR]''${NC} $1"; exit 1; }
    function success() { echo -e "''${GREEN}[SUCCESS]''${NC} $1"; }
    function info() { echo -e "''${MAGENTA}[INFO]''${NC} $1"; }

    # Help Menu Function
    function show_help() {
        echo -e "''${BLUE}󱄅''${NC}  ''${YELLOW}MAYANK ANAND''${NC} | ''${CYAN}PROFESSIONAL WORKSTATION''${NC}"
        echo -e "''${BLUE}󰌢''${NC}  ''${BLUE}$HOSTNAME''${NC} | ''${MAGENTA}  NixOS Unstable''${NC}"
        echo -e "''${YELLOW}──────────────────────────────────────────────────''${NC}"
        echo -e "''${GREEN}󰓅''${NC}  System Uptime: $(uptime -p | sed 's/up //')"
        echo -e "''${BLUE}󰣚''${NC}  Kernel: $(uname -r)"
        echo ""
        echo "Usage: mayank [command]"
        echo "       mayank --help"
        echo ""
        echo -e "''${BLUE}CONFIGURATION:''${NC}"
        echo "  rebuild   - Apply system changes and auto-record to Git"
        echo "  update    - Synchronize flake inputs and rebuild system"
        echo "  rollback  - Instantly revert to the previous generation"
        echo "  history   - View detailed list of system generations"
        echo ""
        echo -e "''${BLUE}MAINTENANCE:''${NC}"
        echo "  clean     - Deep scrub: GC, store optimize, legacy removal"
        echo "  check     - Validate configuration health and syntax"
        echo ""
        echo -e "''${BLUE}UTILITIES:''${NC}"
        echo "  edit      - Open configuration in Neovim editor"
        echo "  search    - Search the Nixpkgs registry for software"
        echo "  shell     - Open an isolated development environment"
        echo ""
        echo "Type 'man mayank' for full system documentation."
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
        
        # Git Tracking (Secure God-Mode Logic)
        cd $CONFIG_DIR
        # 1. Track everything so Nix can see it (required for Flakes)
        git add --all
        
        # 2. Commit everything EXCEPT the secrets file
        GEN=$(nixos-rebuild list-generations | grep current | awk '{print $1}')
        git commit -m "System Update - Generation $GEN - $(date '+%Y-%m-%d %H:%M')" -- hosts/msi-modern14c7m/variables.nix.example modules/ .gitignore flake.nix flake.lock README.md || true
        
        # 3. Apply Rebuild
        sudo nixos-rebuild switch --flake $CONFIG_DIR#$HOSTNAME --no-reexec || error "Rebuild process failed."
        
        # Auto-Push to GitHub (Professional Automation)
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
