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
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.homelab.mounts.slow}/${service}";
    };
    logDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.homelab.mounts.config}/${service}";
    };
    cacheDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.homelab.mounts.config}/${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.homelab.mounts.config}/${service}";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Jellyfin";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "The Free Software Media System";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Media";
    };
  };
  config = lib.mkIf cfg.enable {
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
      user = homelab.user;
      group = homelab.group;

      logDir = cfg.logDir;
      cacheDir = cfg.cacheDir;
      openFirewall = cfg.openFirewall;
      dataDir = cfg.dataDir;
      configDir = cfg.configDir;

    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:8096
      '';
    };
  };

}
