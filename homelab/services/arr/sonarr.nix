{ config, lib, inputs, ... }:
let
  service = "sonarr";
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
      default = "Sonarr";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "TV show collection manager";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "sonarr.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Arr";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = { "${service}ApiKey" = { }; };
    # # FIX: Remove once fixed https://discourse.nixos.org/t/solved-sonarr-is-broken-in-24-11-unstable-aka-how-the-hell-do-i-use-nixpkgs-config-permittedinsecurepackages/56828/13
    # nixpkgs.config.permittedInsecurePackages = [
    #   "dotnet-sdk-6.0.428"
    #   "aspnetcore-runtime-6.0.36"
    # ];
    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      environmentFiles = [ config.sops.secrets."${service}ApiKey".path ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8989
      '';
    };
  };
}
