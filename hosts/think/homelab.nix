{ config, lib, ... }:
let
  nfsMountHealthcheckId = "2bfee5c6-67bd-49b6-9c95-c671a9777c1c";
in
lib.mkMerge [
  {
    # --- Secrets ---
    sops.secrets = {
      wireguardCredentials = { };
    };

    homelab = {
      # --- Core ---
      enable = true;
      baseDomain = "edvardsson.dev";
      timeZone = "Europe/Stockholm";
      caddy.enable = true;

      services = {
        # --- Homepage ---
        # Icons: https://github.com/homarr-labs/dashboard-icons
        homepage = {
          enable = true;
          glancesNetworkInterface = "enp2s0";
        };
        # --- Media / Arr ---
        jellyfin.enable = true;
        bazarr.enable = true;
        prowlarr.enable = true;
        radarr.enable = true;
        sonarr.enable = true;
        jellyseerr.enable = true;
        deluge.enable = true;

        immich.enable = true;

        # --- Monitoring ---
        grafana.enable = true;
        prometheus = {
          enable = true;
          extraNodeTargets = [ "tower:9100" ];
        };

        # --- Admin / UX ---
        cockpit.enable = true;

        healthchecks.enable = true;

        # --- Networking ---
        # adguard = {
        #   enable = true;
        #   rewrites = [
        #     {
        #       domain = "*.${config.homelab.baseDomain}";
        #       answer = "192.168.50.20";
        #     }
        #     {
        #       domain = "www.${config.homelab.baseDomain}";
        #       answer = "A";
        #     }
        #   ];
        # };
        # syncthing.enable = true;

        # --- VPN ---
        wireguard-netns = {
          enable = true;
          configFile = config.sops.secrets.wireguardCredentials.path;
          privateIP = "10.2.0.2";
          dnsIP = "10.2.0.1";
        };
      };
    };
  }
  # --- External services ---
  (lib.custom.addHomelabExternalService {
    name = "Unraid";
    url = "unraid.${config.homelab.baseDomain}";
    proxyTo = "http://10.0.0.42";
    icon = "unraid";
    useACMEHost = config.homelab.baseDomain;
  })
  # --- Storage ---
  (lib.custom.addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data" {
    healthcheck = {
      successUrl = "https://${config.homelab.services.healthchecks.url}/ping/${nfsMountHealthcheckId}";
      failureUrl = "https://${config.homelab.services.healthchecks.url}/ping/${nfsMountHealthcheckId}/fail";
    };
  })
]
