{ config, lib, ... }:
let
  service = "sonarr";
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
      description = "TV show collection manager";
      category = "Arr";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "${service}ApiKey" = { };
    };
    services.${service} = {
      enable = true;
      environmentFiles = [ config.sops.secrets."${service}ApiKey".path ];
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:8989";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
