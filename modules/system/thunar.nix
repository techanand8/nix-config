{
  config,
  pkgs,
  lib,
  vars,
  ...
}:

let
  # Safely check if thunarEnable is set in variables.nix, default to true
  thunarEnable = if vars ? thunarEnable then vars.thunarEnable else true;
in
{
  config = lib.mkIf thunarEnable {
    # --- CORE THUNAR FILE MANAGER ---
    programs.thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-archive-plugin # Integrates context menus for zip/tar/rar extraction
        pkgs.thunar-volman # Automatic management of removable drives (USB/SD)
        pkgs.thunar-media-tags-plugin # Reads media tags (MP3/FLAC) in file properties
      ];
    };

    # --- ADVANCED D-BUS INTEGRATION SERVICES ---
    services.gvfs.enable = true; # Essential for mounting, Trash support, network paths
    services.tumbler.enable = true; # Multi-threaded thumbnail preview daemon
    programs.dconf.enable = true; # Required for saving bookmarks, GTK settings and preferences

    # --- ARCHIVE INTEGRATION & PREVIEW UTILITIES ---
    environment.systemPackages = with pkgs; [
      # Dynamic Thumbnailers for Premium Media Previews
      ffmpegthumbnailer # High-fidelity video thumbnail generation
      poppler-utils # PDF document thumbnail generation
      libgsf # ODF/Office document previews
      shared-mime-info # Correct file type MIME database matching

      # Archive Backend Manager for Thunar-Archive-Plugin
      xarchiver # Lightweight GTK-based archive viewer (fully matches GTK/Ambxst theme presets)
    ];

    # --- GTK SETTINGS AUTO-ADJUSTMENT ---
    # Thunar is a standard GTK3 application. It dynamically inherits your active GTK theme
    # (such as Breeze/Breeze-Dark or custom Nordic presets) set by the Ambxst runtime syncing engine,
    # ensuring perfect visual harmony, glass-morphism, and color accuracy at all times!
  };
}
