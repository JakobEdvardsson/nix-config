{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "deluge";
  homelab = config.homelab;
  cfg = config.homelab.services.${service};
  ns = homelab.services.wireguard-netns.namespace;
  optionsFn = import ../options.nix;
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
      description = "Torrent client";
      category = "Arr";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {

      services.deluge = {
        enable = true;
        web.enable = true;
      };

      services.caddy.virtualHosts."${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8112
        '';
      };

      systemd = lib.mkIf homelab.services.wireguard-netns.enable {
        services.deluged.bindsTo = [ "netns@${ns}.service" ];
        services.deluged.requires = [
          "network-online.target"
          "${ns}.service"
        ];
        services.deluged.serviceConfig.NetworkNamespacePath = [ "/var/run/netns/${ns}" ];
        sockets."deluged-proxy" = {
          enable = true;
          description = "Socket for Proxy to Deluge WebUI";
          listenStreams = [ "58846" ];
          wantedBy = [ "sockets.target" ];
        };
        services."deluged-proxy" = {
          enable = true;
          description = "Proxy to Deluge Daemon in Network Namespace";
          requires = [
            "deluged.service"
            "deluged-proxy.socket"
          ];
          after = [
            "deluged.service"
            "deluged-proxy.socket"
          ];
          unitConfig = {
            JoinsNamespaceOf = "deluged.service";
          };
          serviceConfig = {
            User = config.services.deluge.user;
            Group = config.services.deluge.group;
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:58846";
            PrivateNetwork = "yes";
          };
        };
      };
    })
    (lib.mkIf homelab.services.prometheus.enable {
      # How to set secret for dynamic user: https://github.com/Mic92/sops-nix/issues/198#issuecomment-2661109507

      sops.secrets.delugePassword = { };
      systemd.services.prometheus-deluge-exporter.serviceConfig.LoadCredential =
        "delugePassword:${config.sops.secrets.delugePassword.path}";

      services.prometheus.exporters.${service} = {
        enable = true;
        exportPerTorrentMetrics = true;
        delugePasswordFile = "/run/credentials/prometheus-deluge-exporter.service/delugePassword";
      };

      services.prometheus.scrapeConfigs = [
        {
          job_name = "deluge";
          static_configs = [
            {
              targets = [
                "${config.hostSpec.hostName}:${toString config.services.prometheus.exporters.${service}.port}"
              ];
            }
          ];
        }
      ];
    })
  ];
}
