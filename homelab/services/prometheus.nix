{ config, lib, ... }:
let
  service = "prometheus";
  cfg = config.homelab.services.monitoring;
  homelab = config.homelab;
in
{
  options.homelab.services.monitoring = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    url = lib.mkOption {
      type = lib.types.str;
      default = "prometheus.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "prometheus";
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
      default = "Media";
    };
  };
  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "1m"; # "1m"
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:${toString config.services.${service}.exporters.node.port}" ];
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
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
      enabledCollectors = [
        "systemd"
        "processes"
      ];
      # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
      extraFlags = [
        "--collector.ethtool"
        "--collector.softirqs"
        "--collector.tcpstat"
        "--collector.wifi"
      ];
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.${service}.listenAddress}:${
          toString config.services.${service}.port
        }
      '';
    };
  };
}
