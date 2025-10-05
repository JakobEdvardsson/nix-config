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
  #
  # Sets up:
  #   - The NFS mount at `path`
  #   - Automount with idle timeout
  #   - OnFailure hook and restarter template
  #   - Watchdog that remounts on failure and restarts dependent service
  #   - Service bindings (After/Requires/BindsTo/WantedBy)
  # ------------------------------------------------------------
  # inspo: https://github.com/systemd/systemd/issues/16811
  addNfsMountWithAutomount = path: device: serviceName:
    let
      unitName = lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" path);
    in {
      #### 1. Define the NFS mount
      fileSystems.${path} = {
        device = device;
        fsType = "nfs";
        options = [
          "x-systemd.automount"
          "x-systemd.idle-timeout=60"
          "_netdev"
          "noauto"
          "nofail"
          "noresvport"
          "nfsvers=4"
          "rsize=1048576"
          "wsize=1048576"
          "hard"
          "timeo=600"
          "retrans=2"
        ];
        neededForBoot = false;
      };

      #### 2. Add OnFailure hook for the mount
      systemd.mounts = lib.mkAfter [{
        where = path;
        what = device;
        type = "nfs";
        unitConfig.OnFailure = "automount-restarter@${unitName}.service";
      }];

      #### 3. Automount restarter template
      systemd.services."automount-restarter@" = {
        description = "automount restarter for %i";
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart %i.automount";
        };
      };

      #### 4. Dependent service configuration
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
          ExecStartPre = "${pkgs.coreutils}/bin/mountpoint -q ${path}";
        };
      };

      #### 5. Watchdog service + timer
      systemd.services."nfs-watchdog-${unitName}" = lib.mkDefault {
        description = "NFS watchdog for ${path}";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "nfsWatchdogScript" ''
            #!/bin/sh
            set -eu

            if ! ${pkgs.util-linux}/bin/mountpoint -q ${path}; then
              echo "⚠️  NFS mount ${path} missing — trying to remount..."
              ${pkgs.systemd}/bin/systemctl restart ${unitName}.mount || true
            fi
          '';
        };
      };

      systemd.timers."nfs-watchdog-${unitName}" = lib.mkDefault {
        description = "Watchdog timer for NFS ${path}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1min";
          OnUnitActiveSec = "1min";
        };
      };
    };
}
