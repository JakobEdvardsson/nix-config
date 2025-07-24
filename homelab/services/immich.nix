{
  pkgs,
  config,
  lib,
  ...
}:
let
  service = "immich";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    url = lib.mkOption {
      type = lib.types.str;
      default = "immich.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Immich";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Self-hosted photo and video management solution";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "immich.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Media";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      #systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 immich ${homelab.group} - -" ];
      systemd.services."immich-server".serviceConfig.PrivateDevices = lib.mkForce false;
      users.users.immich.extraGroups = [
        "video"
        "render"
      ];
      services.immich = {
        accelerationDevices = null;
        #group = homelab.group;
        enable = true;
        port = 2283;
        openFirewall = true;
      };
      services.caddy.virtualHosts."${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://${config.services.immich.host}:${toString config.services.immich.port}
        '';
      };
    })

    (lib.mkIf homelab.services.monitoring.enable {
      services.immich.host = "0.0.0.0";

      services.prometheus.scrapeConfigs = [
        {
          job_name = "immich";
          static_configs = [
            {
              targets = [ "10.0.0.34:9183" ];
            }
          ];
        }
      ];

      sops.secrets = {
        prometheusImmichToken = { };
      };

      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
      };

      virtualisation.oci-containers.backend = "podman";

      virtualisation.oci-containers.containers."immich_exporter" = {
        image = "friendlyfriend/prometheus-immich-exporter";
        environment = {
          "IMMICH_HOST" = "10.0.0.34";
          "IMMICH_PORT" = "2283";
          "EXPORTER_PORT" = "9183";
          "EXPORTER_LOG_LEVEL" = "DEBUG";
        };

        ports = [ "9183:9183/tcp" ];
        log-driver = "journald";
        extraOptions = [
          "--network=host"
          "--env-file=${config.sops.secrets.prometheusImmichToken.path}"
        ];
      };
    })
  ];
}
