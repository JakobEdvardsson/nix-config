{ config, lib, ... }:
let
  service = "immich";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.homelab.mounts.fast}/Photos/Immich";
    };
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
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.mediaDir} 0775 immich ${homelab.group} - -" ];
    systemd.services."immich-server".serviceConfig.PrivateDevices = lib.mkForce false;
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    services.immich = {
      group = homelab.group;
      enable = true;
      port = 2283;
      mediaLocation = "${cfg.mediaDir}";
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${toString config.services.immich.port}
      '';
    };
  };
}
