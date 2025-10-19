{ config, lib, pkgs, ... }:
let
  service = "sonarr";
  homelab = config.homelab;
  cfg = config.homelab.services.${service};
  optionsFn = import ../../options.nix;
in {
  options.homelab.services.${service} = optionsFn {
    inherit lib service config homelab;
    homepage = {
      description = "TV show collection manager";
      category = "Arr";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      sops.secrets = { "${service}ApiKey" = { }; };
      sops.templates."${service}ApiKey".content = ''
        ${lib.toUpper service}__AUTH__APIKEY="${
          config.sops.placeholder."${service}ApiKey"
        }"
      '';

      services.${service} = {
        enable = true;
        environmentFiles =
          [ "${config.sops.templates."${service}ApiKey".path}" ];
      };

      services.caddy.virtualHosts."${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8989
        '';
      };
    })
  ];
}
