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
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Supported systems for cross-architecture validation and formatting
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate attributes for each supported system
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

      # Multi-architecture RFC-166 compliant code formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
