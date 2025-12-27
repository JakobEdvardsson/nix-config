{ config, lib, ... }:
let
  service = "jellyseerr";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
  optionsFn = import ../../../options.nix;
in
{
  options.homelab.services.${service} = optionsFn {
    inherit
      lib
      service
      config
      homelab
      ;
    homepage = {
      description = "Media request and discovery manager for Jellyfin";
      category = "Media";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:5055";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
