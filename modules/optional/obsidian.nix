{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.obsidian;
in
{
  options.customOption.obsidian = {
    enable = lib.mkEnableOption "Enable obsidian";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.obsidian ];
  };
}
