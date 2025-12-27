{ lib, pkgs, ... }:
rec {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # include directories
          || (
            (path != "default.nix") # ignore default.nix
            && (lib.strings.hasSuffix ".nix" path) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );

  # ------------------------------------------------------------
  # mkCaddyReverseProxy
  # ------------------------------------------------------------
  # Usage:
  #   services.caddy.virtualHosts."${url}" = lib.mkIf homelab.caddy.enable (
  #     lib.custom.mkCaddyReverseProxy {
  #       proxyTo = "http://127.0.0.1:8080";
  #       useACMEHost = homelab.baseDomain;
  #     }
  #   );
  # ------------------------------------------------------------
  mkCaddyReverseProxy =
    {
      proxyTo ? null,
      useACMEHost ? null,
      extraConfig ? null,
    }:
    let
      config =
        if extraConfig != null then
          extraConfig
        else
          "reverse_proxy ${proxyTo}";
    in
    {
      extraConfig = config;
    }
    // (lib.optionalAttrs (useACMEHost != null) { inherit useACMEHost; });

  # ------------------------------------------------------------
  # addNfsMountWithAutomount
  # ------------------------------------------------------------
  # Usage:
  #   (addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data" {
  #     healthcheckUrl = "https://healthchecks.example/ping/<uuid>/fail";
  #   })
  # Arguments:
  #     where: The mount point directory, e.g., "/mnt/data"
  #     what: The NFS share, e.g., "tower:/mnt/user/data"
  # ------------------------------------------------------------
  # inspo: https://github.com/systemd/systemd/issues/16811
  addNfsMountWithAutomount =
    where: what: { healthcheckUrl ? null }:
    let
      unitName = lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" where);
      healthcheckService = "nfs-healthcheck-${unitName}";
    in
    {
      boot.supportedFilesystems = [ "nfs" ];
      services.rpcbind.enable = true;

      fileSystems.${where} = {
        device = what;
        options = [
          "defaults"
          "x-systemd.automount"
          "noauto"
          "x-systemd.idle-timeout=60"
          "x-systemd.device-timeout=5s"
          "x-systemd.mount-timeout=5s"
          "nofail"
          "_netdev"
        ];
        fsType = "nfs";
        neededForBoot = false;
      };

      systemd.mounts = [
        {
          where = where;
          what = what;
          unitConfig.OnFailure =
            [
              "automount-restarter@${unitName}.service"
            ]
            ++ lib.optional (healthcheckUrl != null) "${healthcheckService}.service";
        }
      ];

      systemd.services."automount-restarter@" = {
        description = "automount restarter for %i";
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart %i.automount";
        };
      };

      systemd.services.${healthcheckService} = lib.mkIf (healthcheckUrl != null) {
        description = "healthchecks.io ping for failed NFS mount ${where}";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.curl}/bin/curl -m 10 --retry 5 ${healthcheckUrl}";
        };
      };

      #  #### Make service depend on the mount
      #  systemd.services.${serviceName} = {
      #    after = [ "${unitName}.automount" "network-online.target" ];
      #    wants = [ "network-online.target" ];
      #    requires = [ "${unitName}.automount" ];
      #    bindsTo = [ "${unitName}.mount" ];
      #    wantedBy = [ "multi-user.target" ];
      #    restartIfChanged = true;
      #
      #    serviceConfig = {
      #      Restart = lib.mkForce "on-failure";
      #      RestartSec = 60;
      #    };
      #  };
    };

  # ------------------------------------------------------------
  # addHomelabExternalService
  # ------------------------------------------------------------
  # Usage:
  #   (addHomelabExternalService {
  #     name = "Unraid";
  #     url = "unraid.${config.homelab.baseDomain}";
  #     proxyTo = "http://10.0.0.42";
  #     icon = "unraid";
  #     description = "Unraid NAS";
  #     category = "External";
  #     href = "https://unraid.${config.homelab.baseDomain}";
  #     siteMonitor = "https://unraid.${config.homelab.baseDomain}/health";
  #     useACMEHost = config.homelab.baseDomain;
  #     extraConfig = "reverse_proxy http://10.0.0.42";
  #   })
  # ------------------------------------------------------------
  addHomelabExternalService =
    {
      name,
      url,
      proxyTo,
      icon ? "server",
      description ? name,
      category ? "External",
      href ? null,
      siteMonitor ? null,
      useACMEHost ? null,
      extraConfig ? null,
    }:
    let
      homepageHref = if href != null then href else "https://${url}";
      homepageMonitor =
        if siteMonitor != null then
          siteMonitor
        else
          homepageHref;
      caddyHost = mkCaddyReverseProxy {
        inherit proxyTo useACMEHost extraConfig;
      };
    in
    {
      homelab = {
        caddy.virtualHosts.${url} = caddyHost;
        services.homepage.external = [
          {
            "${name}" = {
              description = description;
              href = homepageHref;
              siteMonitor = homepageMonitor;
              icon = icon;
              category = category;
            };
          }
        ];
      };
    };
}
