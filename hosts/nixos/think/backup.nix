{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.backup.think;
in

{
  options.homelab.services.backup = {
    enable = lib.mkEnableOption {
      description = "Enable backup for think server";
    };
  };
  config = lib.mkIf (cfg.enable) {
    sops.secrets = {
      resticServerTowerToken = {
        owner = "restic";
        group = "users";
      };
      resticThinkTowerRepo = {
        owner = "restic";
        group = "users";
      };
    };

    users.users.restic = {
      isNormalUser = true;
      createHome = false;
    };

    security.wrappers.restic = {
      source = "${pkgs.restic.out}/bin/restic";
      owner = "restic";
      group = "users";
      permissions = "u=rwx,g=,o=";
      capabilities = "cap_dac_read_search=+ep";
    };

    services.postgresqlBackup = {
      enable = config.services.postgresql.enable;
      databases = config.services.postgresql.ensureDatabases;
    };
    services.mysqlBackup = {
      enable = config.services.mysql.enable;
      databases = config.services.mysql.ensureDatabases;
    };

    services.restic = {
      backups = {
        remote-tower-backup = {
          initialize = true;
          passwordFile = "${config.sops.secrets.resticThinkTowerRepo.path}";
          user = "restic";
          package = pkgs.writeShellScriptBin "restic" ''
            exec /run/wrappers/bin/restic "$@"
          '';
          paths = [
            "${config.services.immich.mediaLocation}"
            "${config.services.grafana.dataDir}"
            "${config.services.mysqlBackup.location}"
            "${config.services.postgresqlBackup.location}"
          ];
          repository = "http://jakobe:${config.sops.placeholder.resticServerTowerToken}@tower:8000/think";
          timerConfig = {
            OnCalendar = "00:00";
            RandomizedDelaySec = "5h";
          };
        };
      };
    };
  };
}
