{ config, lib, inputs, ... }:
let
  service = "radarr";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in {
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Radarr";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Movie collection manager";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "radarr.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Arr";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = { "${service}ApiKey" = { }; };

    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      environmentFiles = [ config.sops.secrets."${service}ApiKey".path ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:7878
      '';
    };
  };
}
