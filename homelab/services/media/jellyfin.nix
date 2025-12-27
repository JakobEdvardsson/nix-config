{
  config,
  pkgs,
  lib,
  ...
}:
let
  service = "jellyfin";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
  optionsFn = import ../../options.nix;
in
{
  options.homelab.services.${service} =
    (optionsFn {
      inherit
        lib
        service
        config
        homelab
        ;
      homepage = {
        description = "The Free Software Media System";
        category = "Media";
      };
    })
    // {
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/${service}";
      };
    };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.jellyfin
      pkgs.jellyfin-ffmpeg
    ];
    nixpkgs.overlays = with pkgs; [
      (final: prev: {
        jellyfin-web = prev.jellyfin-web.overrideAttrs (
          finalAttrs: previousAttrs: {
            installPhase = ''
              runHook preInstall

              # this is the important line
              sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web

              runHook postInstall
            '';
          }
        );
      })
    ];
    services.${service} = {
      enable = true;
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:8096";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
