{ config, lib, ... }:
let
  service = "healthchecks";
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
      description = "Cron Job Monitoring";
      category = "Services";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = {
      healthchecksSecretKey = {
        owner = config.services.${service}.user;
        group = config.services.${service}.group;
      };
    };

    services.${service} = {
      enable = true;
      settings = {
        SITE_ROOT = "https://${cfg.url}";
        SECRET_KEY_FILE = config.sops.secrets.healthchecksSecretKey.path;
        # Add user using healthchecks-manage createsuperuser
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://${toString config.services.${service}.listenAddress}:${
          toString config.services.${service}.port
        }";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
