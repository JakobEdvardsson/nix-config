{ config, lib, ... }:
let
  service = "grafana";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    url = lib.mkOption {
      type = lib.types.str;
      default = "grafana.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Grafana";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Dashboarding tool";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "grafana.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
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
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${toString config.services.${service}.settings.server.http_addr}:${
          toString config.services.${service}.settings.server.http_port
        }
      '';
    };
  };
}
