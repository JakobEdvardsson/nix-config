{ config, lib, pkgs, ... }:
let
  healthcheck-restic-tower = "38badeb9-7644-4857-9758-67172f61b2af";
  healthcheck-restic-borgbase = "2c971425-4415-4bec-be2a-e029c4757186";
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
    resticThinkBorgbaseRepo = {
      owner = "restic";
      group = "users";
    };
    resticThinkBorgbaseRepoURL = {
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
        repository = "rest:http://@tower:8000/think";
        user = "restic";
        package = pkgs.writeShellScriptBin "restic" ''
          exec /run/wrappers/bin/restic "$@"
        '';
        paths = allDataDirs ++ [
          "${config.services.mysqlBackup.location}"
          "${config.services.postgresqlBackup.location}"
          "${config.services.grafana.dataDir}"
        ];
        timerConfig = {
          OnCalendar = "00:00";
          RandomizedDelaySec = "5h";
        };
        backupPrepareCommand =
          "${pkgs.curl}/bin/curl -m 10 --retry 5 https://${config.homelab.services.healthchecks.url}/ping/${healthcheck-restic-tower}/start";
        backupCleanupCommand =
          "${pkgs.curl}/bin/curl -m 10 --retry 5 https://${config.homelab.services.healthchecks.url}/ping/${healthcheck-restic-tower}/$EXIT_STATUS";
      };
      remote-borgbase-backup = {
        initialize = true;
        passwordFile = "${config.sops.secrets.resticThinkBorgbaseRepo.path}";
        repositoryFile =
          "${config.sops.secrets.resticThinkBorgbaseRepoURL.path}";
        user = "restic";
        package = pkgs.writeShellScriptBin "restic" ''
          exec /run/wrappers/bin/restic "$@"
        '';
        # paths = allDataDirs ++ [
        paths = [
          "${config.services.mysqlBackup.location}"
          "${config.services.postgresqlBackup.location}"
          "${config.services.grafana.dataDir}"
        ];
        timerConfig = {
          OnCalendar = "00:00";
          RandomizedDelaySec = "5h";
        };
        backupPrepareCommand =
          "${pkgs.curl}/bin/curl -m 10 --retry 5 https://${config.homelab.services.healthchecks.url}/ping/${healthcheck-restic-borgbase}/start";
        backupCleanupCommand =
          "${pkgs.curl}/bin/curl -m 10 --retry 5 https://${config.homelab.services.healthchecks.url}/ping/${healthcheck-restic-borgbase}/$EXIT_STATUS";
      };
    };
  };

  services.prometheus.scrapeConfigs = [{
    job_name = "restic-tower";
    scrape_interval = "5s";
    static_configs = [{ targets = [ "tower:8000" ]; }];
  }];

}
