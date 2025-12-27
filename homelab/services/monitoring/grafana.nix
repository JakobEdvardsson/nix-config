{ config, lib, ... }:
let
  service = "grafana";
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
      description = "Dashboarding tool";
    };
  };
  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          # Listening Address
          http_addr = "127.0.0.1";
          # and Port
          http_port = 3000;
          # Grafana needs to know on which domain and URL it's running
          domain = "${cfg.url}";
          serve_from_sub_path = true;
        };
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://${toString config.services.${service}.settings.server.http_addr}:${
          toString config.services.${service}.settings.server.http_port
        }";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
