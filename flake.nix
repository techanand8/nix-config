{
  description = "MANX OS: Declarative silicon-grade engineering environment for hardware description and VLSI design";

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

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

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

    # Declarative Disk Management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Statelessness / Impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Declarative Flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Google Antigravity (IDE)
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenLane 2 - Digital ASIC implementation flow
    openlane.url = "github:efabless/openlane2";
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
        {
          hostname,
          platform,
          extraModules ? [ ],
        }:
        let
          vars =
            let
              varsFile = ./hosts/${hostname}/variables.nix;
              exampleFile = ./hosts/${hostname}/variables.nix.example;
            in
            if builtins.pathExists varsFile then import varsFile else import exampleFile;
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              self
              inputs
              platform
              vars
              ;
          };
          modules = [
            {
              nixpkgs.hostPlatform = platform;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.permittedInsecurePackages = [
              ];
              nixpkgs.overlays = [
                (
                  final: prev:
                  if prev.stdenv.hostPlatform.system == "x86_64-linux" then
                    {
                      boost185 = prev.boost;
                      swig4 = prev.swig;
                      clang-tools_14 = prev.clang-tools;
                      standard-magic-vlsi = prev.magic-vlsi;
                    }
                  else
                    { }
                )
                # (
                #   final: prev:
                #   if prev.stdenv.hostPlatform.system == "x86_64-linux" then
                #     (inputs.openlane.inputs.nix-eda.overlays.default final prev)
                #   else
                #     { }
                # )
                # (
                #   final: prev:
                #   if prev.stdenv.hostPlatform.system == "x86_64-linux" then
                #     {
                #       magic-vlsi = final.standard-magic-vlsi;
                #       magic = final.standard-magic-vlsi;
                #     }
                #   else
                #     { }
                # )
                # (
                #   final: prev:
                #   if prev.stdenv.hostPlatform.system == "x86_64-linux" then
                #     (
                #       let
                #         safePrev =
                #           prev
                #           // (
                #             if prev ? yosys then
                #               {
                #                 yosys = prev.yosys.overrideAttrs (old: {
                #                   patches = old.patches or [ ];
                #                 });
                #               }
                #             else
                #               { }
                #           )
                #           // (
                #             if prev ? klayout then
                #               {
                #                 klayout = prev.klayout.overrideAttrs (old: {
                #                   configurePhase = old.configurePhase or "";
                #                 });
                #               }
                #             else
                #               { }
                #           );
                #         baseKlayout = inputs.openlane.inputs.nix-eda.packages.${prev.stdenv.hostPlatform.system}.klayout;
                #       in
                #       (inputs.openlane.overlays.default final safePrev)
                #       // {
                #         klayout =
                #           (baseKlayout.overrideAttrs (old: {
                #             configurePhase = builtins.replaceStrings [ "-without-qtbinding" ] [ "-with-qtbinding" ] (
                #               old.configurePhase or ""
                #             );
                #           }))
                #           // {
                #             pymod = baseKlayout.pymod;
                #           };
                #         openlane = inputs.openlane.packages.${prev.stdenv.hostPlatform.system}.openlane;
                #       }
                #     )
                #   else
                #     { }
                # )
                inputs.nix-cachyos-kernel.overlays.pinned
                (final: prev: {
                  # TEMP WORKAROUND: Fix pipx 1.8.0 test suite expectation drift.
                  # pipx currently fails to build because tests expect "name@ url" but current
                  # packaging/setuptools produces "name @ url" (with a space).
                  #
                  # Why we use sed instead of 'doCheck = false':
                  # By using 'sed' to patch the affected test assertions, we preserve the overall
                  # integrity of the pipx test suite, ensuring other core functionalities are still verified.
                  #
                  # When to remove:
                  # Remove this overlay completely once nixpkgs updates pipx/tests and the command
                  # `nix build .#nixosConfigurations.MANX.pkgs.pipx` compiles successfully without overrides.
                  pipx = prev.pipx.overrideAttrs (oldAttrs: {
                    postPatch = (oldAttrs.postPatch or "") + ''
                      # Regex targets the specific test package specs inside test_package_specifier.py 
                      # and inserts a space before '@' to align assertions with modern setuptools behavior.
                      sed -E -i 's/(nox|black|my-project)(\[[^]]*\])?@/\1\2 @/g' tests/test_package_specifier.py
                    '';
                  });
                  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                    (python-final: python-prev: {
                      # Mirror the same pipx test fix in pythonPackagesExtensions to ensure any
                      # python toolchains pulling pipx from Python package sets are also fixed.
                      pipx = python-prev.pipx.overrideAttrs (oldAttrs: {
                        postPatch = (oldAttrs.postPatch or "") + ''
                          sed -E -i 's/(nox|black|my-project)(\[[^]]*\])?@/\1\2 @/g' tests/test_package_specifier.py
                        '';
                      });
                    })
                  ];

                  # --- BUBBLEWRAP FHS WRAPPER FOR ANTIGRAVITY IDE ---
                  antigravity-fhs = (final.buildFHSEnv or final.buildFHSUserEnv) {
                    name = "antigravity-fhs";
                    targetPkgs =
                      pkgs: with pkgs; [
                        # Core GNU/C++ Development Toolchains
                        gcc
                        gnumake
                        cmake
                        binutils
                        git
                        pkg-config
                        gdb
                        zlib

                        # Python & Deep Learning Ecosystem
                        python3
                        python3Packages.pip
                        python3Packages.virtualenv
                        python3Packages.setuptools

                        # Silicon & VLSI Hardware Engineering Toolchains
                        verilator
                        iverilog
                        yosys

                        # Graphics, Audio, and OS Library Bindings
                        libx11
                        libxcomposite
                        libxdamage
                        libxext
                        libxfixes
                        libxi
                        libxrandr
                        libxrender
                        libxtst
                        libxcb
                        libxshmfence
                        libGL
                        libva
                        libxkbcommon
                        nss
                        nspr
                        alsa-lib
                        dbus
                        glib
                        icu
                        openssl
                        curl
                        stdenv.cc.cc.lib
                        zstd
                      ];
                    runScript = "${
                      inputs.antigravity-nix.packages.${final.stdenv.hostPlatform.system}.default
                    }/bin/antigravity";
                  };
                })
              ];
            }
            ./hosts/${hostname}/configuration.nix
            inputs.disko.nixosModules.disko
            inputs.ambxst.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = {
                inherit inputs platform vars;
              };
              home-manager.users."${vars.username}" = {
                imports = [
                  inputs.nixvim.homeModules.nixvim
                  ./modules/home/home-user.nix
                ];
              };
            }
          ]
          ++ extraModules;
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
          # Parse arguments to separate flags from target files
          args=()
          files=()
          for arg in "$@"; do
            if [[ "$arg" == -* ]]; then
              args+=("$arg")
            else
              files+=("$arg")
            fi
          done

          if [ ''${#files[@]} -eq 0 ]; then
            # Auto-find all nix files and format/check them
            find . -name "*.nix" -not -path "./result/*" -not -path "./.git/*" -print0 | xargs -0 ${pkgs.nixfmt}/bin/nixfmt "''${args[@]}"
          else
            exec ${pkgs.nixfmt}/bin/nixfmt "$@"
          fi
        ''
      );

      # Development Environments
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              nil
              statix
              deadnix
            ];
            shellHook = ''
              echo "❄️MANX Engineering Environment Active"
            '';
          };
        }
      );
    };
}
