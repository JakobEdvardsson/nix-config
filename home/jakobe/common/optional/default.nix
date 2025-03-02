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
    ./media
    ./tools
    ./xdg.nix
    ./development

    ./wm
    ./syncthing
  ];
}
