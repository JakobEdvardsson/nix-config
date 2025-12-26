{ config, lib, ... }:
let
  service = "prometheus";
  cfg = config.homelab.services.prometheus;
  homelab = config.homelab;
in
{
  options.homelab.services.prometheus = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    url = lib.mkOption {
      type = lib.types.str;
      default = "prometheus.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Prometheus";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Event monitoring and alerting";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "prometheus.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
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
                "tower:9100"
              ];
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
      ];
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

    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.${service}.listenAddress}:${
          toString config.services.${service}.port
        }
      '';
    };
  };
}
