{ config, lib, pkgs, ... }:
let
  # Get all enabled homelab services with dataDirs
  enabledServices = lib.attrsets.filterAttrs
    (name: svc: svc ? enable && svc.enable && svc ? dataDirs)
    config.homelab.services;

  # Flatten all dataDirs into a single list
  allDataDirs = lib.flatten
    (lib.attrsets.mapAttrsToList (name: svc: svc.dataDirs) enabledServices);
in {
  sops.secrets = {
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
        paths = allDataDirs ++ [
          "${config.services.mysqlBackup.location}"
          "${config.services.postgresqlBackup.location}"
          "${config.services.grafana.dataDir}"
        ];
        repository = "rest:http://@tower:8000/think";
        timerConfig = {
          OnCalendar = "00:00";
          RandomizedDelaySec = "5h";
        };
      };
    };
  };

  services.prometheus.scrapeConfigs = [{
    job_name = "restic-tower";
    scrape_interval = "5s";
    static_configs = [{ targets = [ "tower:8000" ]; }];
  }];

}
