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
      baseDomain = "edvardsson.dev";
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

        immich.enable = true;

        grafana.enable = true;
        monitoring.enable = true; # prometheus

        cockpit.enable = true;

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

    # NFS Storage
    # Immich
    fileSystems."/mnt/immich" = {
      device = "tower:/mnt/user/immich";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "x-systemd.device-timeout=10"
        "_netdev"
        "nofail"
        "noresvport"
        "nfsvers=4"
        "rsize=1048576"
        "wsize=1048576"
        "hard"
        "timeo=600"
        "retrans=2"
      ];
      neededForBoot = false;
    };

    systemd.services."immich-server" = {
      after = [ "mnt-immich.mount" ];
      requires = [ "mnt-immich.mount" ];
    };

    # services.caddy.virtualHosts = {
    #   "home-assistant.edvardsson.tech" = {
    #     useACMEHost = config.homelab.baseDomain;
    #     extraConfig = ''
    #       reverse_proxy http://192.168.50.10:8123
    #     '';
    #   };
    #   "router.edvardsson.tech" = {
    #     useACMEHost = config.homelab.baseDomain;
    #     extraConfig = ''
    #       reverse_proxy http://192.168.50.1
    #     '';
    #   };
    # };
  };
}
