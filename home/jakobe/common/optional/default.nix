{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./browsers
    ./comms
    # ./gaming
    ./hyprland
    ./media
    ./tools
    ./waybar
    ./sops.nix
    ./xdg.nix
  ];
}
