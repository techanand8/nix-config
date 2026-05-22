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
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      # Systems we support for the build and formatting
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Helper to generate settings for each system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      hostPlatform = "x86_64-linux";
      vars = import ./hosts/manx/variables.nix;
    in
    {
      nixosConfigurations.MANX = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars hostPlatform; };
        modules = [
          {
            nixpkgs.hostPlatform = hostPlatform;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
          }
          ./hosts/manx/configuration.nix
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.ambxst.nixosModules.default

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit inputs vars hostPlatform; };
            home-manager.users."${vars.username}" = {
              imports = [
                inputs.nixvim.homeModules.nixvim
                ./modules/home/mayank.nix
              ];
            };
          }
        ];
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
