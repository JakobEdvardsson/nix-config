{ config, lib, ... }:
let
  service = "prowlarr";
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
      description = "PVR indexer";
      category = "Arr";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:9696";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
