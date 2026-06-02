{ pkgs, inputs, ... }:

{
  # Dedicated container for managing extra system apps
  environment.systemPackages = [
    # Zen Browser (natively packaged via trusted flake input)
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Chromium Browser (With high-performance hardware acceleration & account support)
    pkgs.chromium

    # Add future additional system-level packages here:
    # pkgs.some-app
    pkgs.obs-studio
  ];
}
