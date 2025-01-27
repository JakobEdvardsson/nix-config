{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customHome.swaync;
in
{

  options.customHome.swaync = {
    enable = lib.mkEnableOption "Enable swaync as the notificaton daemon for Wayland.";
  };

  config = lib.mkIf cfg.enable {
    services.swaync.enable = true;
  };
}
