{ pkgs, config, lib, ... }:
let cfg = config.customHome.media;
in {
  options.customHome.media = {
    enable = lib.mkEnableOption "Nice to have media things";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ffmpeg spotify vlc mpv ];
  };
}
