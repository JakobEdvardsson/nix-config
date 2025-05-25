{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.customHome.tools;
in
{
  options.customHome.tools = {
    enable = lib.mkEnableOption "Nice to have tools";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      # Device imaging
      rpi-imager
      mediawriter # fedora

      # Productivity
      drawio
      grimblast
      caprine

      # Media production
      obs-studio

      # Office suite
      libreoffice
    ];
  };
}
