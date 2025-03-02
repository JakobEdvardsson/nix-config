{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.customHome.syncthing;
in
{
  options.customHome.syncthing = {
    enable = lib.mkEnableOption "Syncthing, continuous file synchronization";
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
}
