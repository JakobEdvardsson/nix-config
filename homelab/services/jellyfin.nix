# default = "The Free Software Media System";
{ config, lib, pkgs, ... }:
let
  service = "jellyfin";
  homelab = config.homelab;
  cfg = config.homelab.services.${service};
  optionsFn = import ../options.nix;
in {
  options.homelab.services.${service} = optionsFn {
    inherit lib service config homelab;
    homepage = {
      description = "The Free Software Media System";
      category = "Arr";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages =
        [ pkgs.jellyfin pkgs.jellyfin-web pkgs.jellyfin-ffmpeg ];

      services.${service} = { enable = true; };

      services.caddy.virtualHosts."${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8096
        '';
      };
    })
  ];
}
