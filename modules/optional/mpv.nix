# media player
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.mpv;
in
{
  options.customOption.mpv = {
    enable = lib.mkEnableOption "Enable mpv";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mpv ];
  };
}
