{ config, lib, ... }:
lib.mkMerge [
  {
    sops.secrets = {
      cloudflareDnsApiCredentials = { };
      wireguardCredentials = { };
    };

    homelab = {
      enable = true;
      baseDomain = "edvardsson.dev";
      cloudflare.dnsCredentialsFile =
        config.sops.secrets.cloudflareDnsApiCredentials.path;
      timeZone = "Europe/Stockholm";
      mounts = {
        config = "/appdata";
        slow = "/mnt/slow";
        fast = "/mnt/fast";
      };

      services = {
        enable = true;
        # homepage icons can be found at https://github.com/homarr-labs/dashboard-icons

        # Categories: Arr, Media, Services
        homepage = {
          enable = true;
          external = [{
            "Local Syncthing" = {
              href = "http://127.0.0.1:8384/";
              siteMonitor = "http://127.0.0.1:8384/";
              description = "Local Syncthing";
              icon = "syncthing";
              category = "Services";
            };
          }];
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
  (lib.custom.addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data"
    "deluged")
  (lib.custom.addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data"
    "delugeweb")
]
