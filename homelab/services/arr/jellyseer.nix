{ config, lib, pkgs, ... }:
let
  service = "jellyseerr";
  homelab = config.homelab;
  cfg = config.homelab.services.${service};
  optionsFn = import ../../options.nix;
in {
  options.homelab.services.${service} = optionsFn {
    inherit lib service config homelab;
    homepage = {
      description = "Media request and discovery manager for Jellyfin";
      category = "Arr";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {

      services.${service} = { enable = true; };

      services.caddy.virtualHosts."${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:5055
        '';
      };
    })
  ];
}
