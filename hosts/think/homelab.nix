{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkMerge [
  {
    sops.secrets = {
      wireguardCredentials = { };
    };

    homelab = {
      enable = true;
      baseDomain = "edvardsson.dev";
      timeZone = "Europe/Stockholm";
      caddy.enable = true;

      services = {
        # homepage icons can be found at https://github.com/homarr-labs/dashboard-icons

        # Categories: Arr, Media, Services
        homepage = {
          enable = true;
          glancesNetworkInterface = "enp2s0";
          external = [
            {
              "Local Syncthing" = {
                href = "http://127.0.0.1:8384/";
                siteMonitor = "http://127.0.0.1:8384/";
                description = "Local Syncthing";
                icon = "syncthing";
                category = "Services";
              };
            }
          ];
        };
        # # Arr
        # jellyfin.enable = true;
        # bazarr.enable = true;
        # prowlarr.enable = true;
        # radarr.enable = true;
        # sonarr.enable = true;
        # jellyseerr.enable = true;
        deluge.enable = true;

        immich.enable = true;

        grafana.enable = true;
        prometheus = {
          enable = true;
          extraNodeTargets = [ "tower:9100" ];
        };

        cockpit.enable = true;

        healthchecks.enable = true;

        # adguard.enable = true;
        adguard.rewrites = [
          {
            domain = "*.${config.homelab.baseDomain}";
            answer = "192.168.50.20";
          }
          {
            domain = "www.${config.homelab.baseDomain}";
            answer = "A";
          }
        ];
        # syncthing.enable = true;

        wireguard-netns = {
          enable = true;
          configFile = config.sops.secrets.wireguardCredentials.path;
          privateIP = "10.2.0.2";
          dnsIP = "10.2.0.1";
        };
      };
    };
  }
  (lib.custom.addHomelabExternalService {
    name = "Unraid";
    url = "unraid.${config.homelab.baseDomain}";
    proxyTo = "http://10.0.0.42";
    icon = "unraid";
    useACMEHost = config.homelab.baseDomain;
  })
  (lib.custom.addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data")
]
