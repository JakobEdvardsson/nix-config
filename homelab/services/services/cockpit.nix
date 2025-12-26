{ config, lib, ... }:
let
  service = "cockpit";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    url = lib.mkOption {
      type = lib.types.str;
      default = "cockpit.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Cockpit";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Web-based graphical interface for servers";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "cockpit.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
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
