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
  # addNfsServiceWithAutomount
  # ------------------------------------------------------------
  # Usage:
  #   (addNfsServiceWithAutomount "/mnt/data" "deluged")
  #
  # Sets up:
  #   - An automount restarter template
  #   - OnFailure hook for the given mount
  #   - Service bindings (After/Requires/BindsTo/WantedBy)
  # ------------------------------------------------------------
  addNfsServiceWithAutomount = path: serviceName:
    let
      unitName = lib.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" path);
    in {
      #### 1. Template unit that restarts failed automounts
      systemd.services."automount-restarter@" = {
        description = "automount restarter for %i";
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
          ExecStart = "${pkgs.systemd}/bin/systemctl restart %i.automount";
        };
      };

      #### 2. Add OnFailure hook to the mount
      systemd.mounts = [{
        where = path;
        unitConfig.OnFailure = "automount-restarter@${unitName}.service";
      }];

      #### 3. Configure the dependent service (e.g., deluged)
      systemd.services.${serviceName} = {
        after = [ "${unitName}.automount" "network-online.target" ];
        requires = [ "${unitName}.automount" ];
        bindsTo = [ "${unitName}.mount" ];
        wantedBy = [ "${unitName}.automount" ];
        restartIfChanged = true;
        serviceConfig = {
          Restart = lib.mkForce "on-failure";
          RestartSec = 10;
        };
      };
    };
}
