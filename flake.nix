{
  description = "My NixOS Configuration";

  inputs = {
    # Using unstable for the latest VLSI and AI/ML tools
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # AMD Specific hardware optimizations
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland flake for the absolute latest features
    hyprland.url = "github:hyprwm/Hyprland";

    # Ambxst shell flake
    ambxst.url = "github:Axenide/Ambxst";

    # Nixvim Neovim management
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Official community CachyOS kernel inputs
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Zen Browser - Trusted Community Flake (optimized, auto-updated binary wrap)
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Secrets Management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Statelessness / Impermanence
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      # Systems we support for the build and formatting
      supportedSystems = [ "x86_64-linux" ];

      # Helper to generate settings for each system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Centralized System Builder
      mkSystem = 
        { hostname, platform, extraModules ? [] }: 
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit self inputs platform;
            vars = import ./hosts/${hostname}/variables.nix;
          };
          modules = [
            {
              nixpkgs.hostPlatform = platform;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
            }
            ./hosts/${hostname}/configuration.nix
            inputs.ambxst.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = { 
                inherit inputs platform; 
                vars = import ./hosts/${hostname}/variables.nix;
              };
              home-manager.users."${(import ./hosts/${hostname}/variables.nix).username}" = {
                imports = [
                  inputs.nixvim.homeModules.nixvim
                  ./modules/home/home-user.nix
                ];
              };
            }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        # --- Primary Workstation ---
        MANX = mkSystem {
          hostname = "manx";
          platform = "x86_64-linux";
          extraModules = [
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-gpu-amd
            inputs.nixos-hardware.nixosModules.common-pc-ssd
          ];
        };

        # --- Portable Engineering Laptop ---
        # Note: Requires generating hardware-configuration.nix on target machine
        LAPTOP = mkSystem {
          hostname = "laptop";
          platform = "x86_64-linux";
          extraModules = [
            # Add laptop-specific hardware modules here (e.g. battery, touch-pad)
            inputs.nixos-hardware.nixosModules.common-pc-laptop
            inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
          ];
        };
      };

      # Automated Nix Formatter (Multi-architecture)
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellScriptBin "nixfmt" ''
          if [ "$#" -eq 0 ]; then
            # Auto-find all nix files and format them if no files are specified
            find . -name "*.nix" -not -path "./result/*" -print0 | xargs -0 ${pkgs.nixfmt}/bin/nixfmt
          else
            exec ${pkgs.nixfmt}/bin/nixfmt "$@"
          fi
        ''
      );
    };
}
