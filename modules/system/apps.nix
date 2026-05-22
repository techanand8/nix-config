{ pkgs, inputs, ... }:

{
  # Dedicated container for managing your extra system apps
  environment.systemPackages = [
    # Zen Browser (natively packaged via trusted flake input)
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Add any extra apps you want in the future here:
    # pkgs.some-app
  ];
}
