{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customHome.development;
in
{

  options.customHome.development = {
    enable = lib.mkEnableOption "Enable development tooling";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # programming
      nodejs
      bun

      # tooling
      gcc
      gnumake

      # networkig tools
      dnsutils
      nmap
    ];
  };
}
