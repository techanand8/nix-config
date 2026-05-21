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
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, hyprland, ambxst, nixvim, nix-cachyos-kernel, ... }@inputs:
    let
      hostPlatform = "x86_64-linux";
      vars = import ./hosts/msi-modern14c7m/variables.nix;
    in
    {
      nixosConfigurations.msi-modern14c7m = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars hostPlatform; };
        modules = [
          {
            nixpkgs.hostPlatform = hostPlatform;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
          }
          ./hosts/msi-modern14c7m/configuration.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-pc-ssd
          ambxst.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit inputs vars hostPlatform; };
            home-manager.users."${vars.username}" = {
              imports = [
                nixvim.homeModules.nixvim
                ./modules/home/mayank.nix
              ];
            };
          }
        ];
      };
    };
}
