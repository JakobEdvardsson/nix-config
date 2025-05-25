{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customOption.docker;
in
{

  options.customOption.docker = {
    enable = lib.mkEnableOption "Enable docker";
  };

  config = lib.mkIf cfg.enable {

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
