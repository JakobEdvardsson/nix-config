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
    ./media
    ./tools
    ./sops.nix
    ./xdg.nix

    ./wm
  ];
}
