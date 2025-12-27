{ config, lib, ... }:
let
  service = "prometheus";
  cfg = config.homelab.services.prometheus;
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
        description = "Event monitoring and alerting";
      };
    })
    // {
      extraNodeTargets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "1m";
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "localhost:${toString config.services.${service}.exporters.node.port}"
              ]
              ++ cfg.extraNodeTargets;
            }
          ];
        }
        {
          job_name = "systemd";
          static_configs = [
            {
              targets = [
                "localhost:${toString config.services.${service}.exporters.systemd.port}"
              ];
            }
          ];
        }
        {
          job_name = "prometheus";
          scrape_interval = "5s";
          static_configs = [
            {
              targets = [ "localhost:${toString config.services.${service}.port}" ];
            }
          ];
        }
      ]
      ++ lib.optional config.customOption.comin.enable {
        job_name = "comin";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.comin.exporter.port}"
            ];
          }
        ];
      };
    };

    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [ "processes" ];
      extraFlags = [
        "--collector.ethtool"
        "--collector.softirqs"
        "--collector.tcpstat"
        "--collector.wifi"
      ];
    };

    # https://discourse.nixos.org/t/systemd-exporter-couldnt-get-dbus-connection-read-unix-run-dbus-system-bus-socket-recvmsg-connection-reset-by-peer/64367/2
    services.dbus.implementation = "broker";

    services.prometheus.exporters.systemd = {
      enable = true;
      port = 9558;
    };

    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://${config.services.${service}.listenAddress}:${
          toString config.services.${service}.port
        }";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
