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
      /*
        samba = {
          enable = true;
          passwordFile = config.sops.secrets.sambaPassword.path;
          shares = {
            Backups = {
              path = "${hl.mounts.merged}/Backups";
            };
          };
        };
      */
      services = {
        enable = true;
        /*
          backup = {
            enable = true;
            passwordFile = config.sops.secrets.resticPassword.path;
            s3.enable = true;
            s3.url = "https://s3.eu-central-003.backblazeb2.com/notthebee-ojfca-backups";
            s3.environmentFile = config.sops.secrets.resticBackblazeEnv.path;
            local.enable = true;
          };
        */
        # homepage icons can be found at https://github.com/homarr-labs/dashboard-icons
        homepage = {
          enable = true;
          external = [
            {
              "Asus Router" = {
                href = "https://router.edvardsson.tech";
                siteMonitor = "http://192.168.50.1";
                description = "Asus Router";
                icon = "asus-router.svg";
              };
            }
            {
              "Home Assistant" = {
                href = "https://home-assistant.edvardsson.tech";
                siteMonitor = "http://192.168.50.10:8123";
                description = "Home Assistant";
                icon = "home-assistant";
              };
            }
            {
              "Local Syncthing" = {
                href = "http://127.0.0.1:8384/";
                siteMonitor = "http://127.0.0.1:8384/";
                description = "Local Syncthing";
                icon = "syncthing";
              };
            }

          ];
        };
        # Arr
        jellyfin.enable = true;
        bazarr.enable = true;
        prowlarr.enable = true;
        radarr.enable = true;
        sonarr.enable = true;
        jellyseerr.enable = true;
        deluge.enable = true;

        adguard.enable = true;
        syncthing.enable = true;
        immich.enable = true;

        wireguard-netns = {
          enable = true;
          configFile = config.sops.secrets.wireguardCredentials.path;
          privateIP = "10.2.0.2";
          dnsIP = "10.2.0.1";
        };

        # paperless = {
        #   enable = true;
        #   passwordFile = config.sops.secrets.paperlessPassword.path;
        # };
        # sabnzbd.enable = true;
        # sonarr.enable = true;
        # radarr.enable = true;
        # bazarr.enable = true;
        # prowlarr.enable = true;
        # navidrome = {
        #   enable = true;
        #   environmentFile = config.sops.secrets.navidromeEnv.path;
        # };
        # nextcloud = {
        #   enable = true;
        #   adminpassFile = config.sops.secrets.nextcloudAdminPassword.path;
        #   cloudflared = {
        #     tunnelId = "cc246d42-a03d-41d4-97e2-48aa15d47297";
        #     credentialsFile = config.sops.secrets.nextcloudCloudflared.path;
        #   };
        # };
        # vaultwarden = {
        #   enable = true;
        #   cloudflared = {
        #     tunnelId = "3bcbbc74-3667-4504-9258-f272ce006a18";
        #     credentialsFile = config.sops.secrets.vaultwardenCloudflared.path;
        #   };
        # };
        # microbin = {
        #   enable = true;
        #   cloudflared = {
        #     tunnelId = "216d72b6-6b2b-412f-90bc-1a44c1264871";
        #     credentialsFile = config.sops.secrets.microbinCloudflared.path;
        #   };
        # };
        # audiobookshelf.enable = true;
        # deluge.enable = true;
        # deemix.enable = true;
        # slskd = {
        #   enable = true;
        #   environmentFile = config.sops.secrets.slskdEnv.path;
        # };
        # wireguard-netns = {
        #   enable = true;
        #   configFile = config.sops.secrets.wireguardCredentials.path;
        #   privateIP = "10.100.0.2";
        #   dnsIP = "10.100.0.1";
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
