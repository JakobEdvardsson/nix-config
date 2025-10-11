{ lib, pkgs, ... }: {
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
  scanPaths = path:
    builtins.map (f: (path + "/${f}")) (builtins.attrNames
      (lib.attrsets.filterAttrs (path: _type:
        (_type == "directory") # include directories
        || ((path != "default.nix") # ignore default.nix
          && (lib.strings.hasSuffix ".nix" path) # include .nix files
        )) (builtins.readDir path)));

  # ------------------------------------------------------------
  # addNfsMountWithAutomount
  # ------------------------------------------------------------
  # Usage:
  #   (addNfsMountWithAutomount "/mnt/data" "tower:/mnt/user/data" "deluged")
  # Arguments:
  #     where: The mount point directory, e.g., "/mnt/data"
  #     what: The NFS share, e.g., "tower:/mnt/user/data"
  #     serviceName: The name of the dependent service, e.g., "deluged"
  # ------------------------------------------------------------
  # inspo: https://github.com/systemd/systemd/issues/16811
  addNfsMountWithAutomount = where: what: serviceName:
    let
      unitName =
        lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" where);
    in {
      boot.supportedFilesystems = [ "nfs" ];
      services.rpcbind.enable = true;
      #### 1. Define the NFS mount
      systemd.mounts = [{
        type = "nfs";
        mountConfig = {
          Options = [
            "defaults"
            "noauto"
            "x-systemd.idle-timeout=600"
            "nofail"
            "_netdev"
          ];
        };
        what = what; # "tower:/mnt/user/data"
        where = where; # "/mnt/data"
        unitConfig.OnFailure = "automount-restarter@${unitName}.service";
      }];

      #### 2. Define the NFS automounts
      systemd.automounts = [{
        wantedBy = [ "multi-user.target" ];
        automountConfig = { TimeoutIdleSec = "600"; };
        where = where;
      }];

      #### 3. Automount restarter
      systemd.services."automount-restarter@" = {
        description = "automount restarter for %i";
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart %i.automount";
        };
      };

      #### 4. Make service depend on the mount
      systemd.services.${serviceName} = {
        after = [ "${unitName}.automount" "network-online.target" ];
        wants = [ "network-online.target" ];
        requires = [ "${unitName}.automount" ];
        bindsTo = [ "${unitName}.mount" ];
        wantedBy = [ "multi-user.target" ];
        restartIfChanged = true;

        serviceConfig = {
          Restart = lib.mkForce "on-failure";
          RestartSec = 60;
        };
      };
    };
}
