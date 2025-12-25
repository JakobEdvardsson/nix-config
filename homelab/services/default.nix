{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = lib.custom.scanPaths ./.;

  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
  };

}
