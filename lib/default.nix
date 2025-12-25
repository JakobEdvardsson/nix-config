{ lib, pkgs, ... }:
{
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
  # addNfsMountWithAutomount
  # ------------------------------------------------------------
  # Usage:
  #   (addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data")
  # Arguments:
  #     where: The mount point directory, e.g., "/mnt/data"
  #     what: The NFS share, e.g., "tower:/mnt/user/data"
  # ------------------------------------------------------------
  # inspo: https://github.com/systemd/systemd/issues/16811
  addNfsMountWithAutomount =
    where: what:
    let
      unitName = lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" where);
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
          unitConfig.OnFailure = "automount-restarter@${unitName}.service";
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
      caddyHost =
        {
          extraConfig =
            if extraConfig != null then
              extraConfig
            else
              "reverse_proxy ${proxyTo}";
        }
        // (lib.optionalAttrs (useACMEHost != null) { useACMEHost = useACMEHost; });
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
