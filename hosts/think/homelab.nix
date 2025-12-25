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
        prometheus.enable = true; # prometheus

        cockpit.enable = true;

        healthchecks.enable = true;

        # adguard.enable = true;
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
  (lib.custom.addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data")
]
