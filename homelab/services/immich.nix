{ config, lib, ... }:
let
  service = "immich";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
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
      description = "Self-hosted photo and video management solution";
      category = "Media";
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
      services.${service} = {
        accelerationDevices = null;
        enable = true;
        port = 2283;
        openFirewall = true;
      };
      services.caddy.virtualHosts."${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://${config.services.${service}.host}:${toString config.services.${service}.port}
        '';
      };
    })

    (lib.mkIf homelab.services.prometheus.enable {
      services.${service}.host = "0.0.0.0";

      services.prometheus.scrapeConfigs = [
        {
          job_name = "immich";
          static_configs = [ { targets = [ "${config.hostSpec.hostName}:9183" ]; } ];
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
          "IMMICH_HOST" = config.hostSpec.hostName;
          "IMMICH_PORT" = "2283";
          "EXPORTER_PORT" = "9183";
          "EXPORTER_LOG_LEVEL" = "WARNING";
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
