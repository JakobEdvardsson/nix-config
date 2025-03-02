{ config, lib, ... }:
let
  service = "syncthing";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${homelab.mounts.fast}/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Syncthing";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Continuous file synchronization";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "syncthing.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Services";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir}/syncthing 0775 ${homelab.user} ${homelab.group} - -"
    ];

    networking.firewall = {
      allowedTCPPorts = [
        8384
        22000
      ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      guiAddress = "0.0.0.0:8384";
      overrideFolders = false;
      overrideDevices = false;
      dataDir = "${homelab.mounts.fast}/Syncthing";
      configDir = "${cfg.configDir}/syncthing";
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8384
      '';
    };
  };
}
