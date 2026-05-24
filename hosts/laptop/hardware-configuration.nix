{
  imports = [ ];
  fileSystems."/" = { device = "/dev/null"; fsType = "btrfs"; };
  fileSystems."/persist" = { device = "/dev/null"; fsType = "btrfs"; };
}
