{ pkgs, config, lib, ... }:
let cfg = config.customHome.comms;
in {
  options.customHome.comms = {
    enable = lib.mkEnableOption "Nice to have comms things";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
      vesktop
      teams-for-linux
      zoom-us
      slack
    ];
  };
}
