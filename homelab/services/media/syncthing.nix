{ config, lib, ... }:
let
  service = "syncthing";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
  optionsFn = import ../../options.nix;
in
{
  options.homelab.services.${service} =
    (optionsFn {
      inherit
        lib
        service
        config
        homelab
        ;
      homepage = {
        description = "Continuous file synchronization";
      };
    })
    // {
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/${service}";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/${service}";
      };
    };
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        8384
        22000
      ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
    services.${service} = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
      overrideFolders = false;
      overrideDevices = false;
      dataDir = cfg.dataDir;
      configDir = cfg.configDir;
    };

    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:8384";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
