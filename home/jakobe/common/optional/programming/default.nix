{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customHome.programming;
in
{

  options.customHome.programming = {
    enable = lib.mkEnableOption "Enable programming tooling";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # tooling
      gcc
      gnumake
    ];
  };
}
