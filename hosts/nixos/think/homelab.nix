{ config, lib, ... }:
let
  hl = config.homelab;
in
{
  config = {
    sops.secrets = {
      cloudflareDnsApiCredentials = { };
      wireguardCredentials = { };
    };

    homelab = {
      enable = true;
      baseDomain = "edvardsson.tech";
      cloudflare.dnsCredentialsFile = config.sops.secrets.cloudflareDnsApiCredentials.path;
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
          external = [
            {
              "Asus Router" = {
                href = "https://router.edvardsson.tech";
                siteMonitor = "http://192.168.50.1";
                description = "Asus Router";
                icon = "asus-router.svg";
                category = "Services";
              };
            }
            {
              "Home Assistant" = {
                href = "https://home-assistant.edvardsson.tech";
                siteMonitor = "http://192.168.50.10:8123";
                description = "Home Assistant";
                icon = "home-assistant";
                category = "Services";
              };
            }
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
        # deluge.enable = true;

        # adguard.enable = true;
        # syncthing.enable = true;

        # wireguard-netns = {
        #   enable = true;
        #   configFile = config.sops.secrets.wireguardCredentials.path;
        #   privateIP = "10.2.0.2";
        #   dnsIP = "10.2.0.1";
        # };
      };
    };
    services.caddy.virtualHosts = {
      "home-assistant.edvardsson.tech" = {
        useACMEHost = config.homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://192.168.50.10:8123
        '';
      };
      "router.edvardsson.tech" = {
        useACMEHost = config.homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://192.168.50.1
        '';
      };
    };
  };
}
