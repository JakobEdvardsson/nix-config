{ config, lib, ... }:
let
  service = "cockpit";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
  optionsFn = import ../../options.nix;
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
      description = "Web-based graphical interface for servers";
    };
  };
  config = lib.mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      port = 9091;
      allowed-origins = [ "https://${cfg.url}" ];
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:${toString config.services.cockpit.port}";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
