{
  config,
  lib,
  pkgs,
  ...
}:
let
  healthcheck-restic-tower = "38badeb9-7644-4857-9758-67172f61b2af";
  healthcheck-restic-borgbase = "2c971425-4415-4bec-be2a-e029c4757186";
  healthcheck-restic-ugreen = "2a6e2192-b868-404d-9561-57a5513cde1b";
  # Get all enabled homelab services with dataDirs
  enabledServices = lib.attrsets.filterAttrs (
    name: svc: svc ? enable && svc.enable && svc ? dataDirs
  ) config.homelab.services;

  # Flatten all dataDirs into a single list
  allDataDirs = lib.flatten (lib.attrsets.mapAttrsToList (name: svc: svc.dataDirs) enabledServices);

  resticPaths = allDataDirs ++ [
    "${config.services.mysqlBackup.location}"
    "${config.services.postgresqlBackup.location}"
    "${config.services.grafana.dataDir}"
  ];

  resticTimerConfig = {
    OnCalendar = "00:00";
    RandomizedDelaySec = "5h";
  };

  mkResticHealthcheckCommands =
    healthcheckId:
    let
      healthchecksUrl = config.homelab.services.healthchecks.url;
    in
    {
      backupPrepareCommand = lib.custom.mkHealthcheckCommand "https://${healthchecksUrl}/ping/${healthcheckId}/start";
      backupCleanupCommand = lib.custom.mkHealthcheckCommand "https://${healthchecksUrl}/ping/${healthcheckId}/";
      backupFailCommand = lib.custom.mkHealthcheckCommand "https://${healthchecksUrl}/ping/${healthcheckId}/fail";
    };
in
lib.mkMerge [
  {
    sops.secrets = {
      resticThinkTowerRepo = {
        owner = "restic";
        group = "users";
      };
      resticThinkTowerURL = {
        owner = "restic";
        group = "users";
      };
      resticThinkBorgbaseRepo = {
        owner = "restic";
        group = "users";
      };
      resticThinkBorgbaseURL = {
        owner = "restic";
        group = "users";
      };
      resticThinkUgreenRepo = {
        owner = "restic";
        group = "users";
      };
      resticThinkUgreenURL = {
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

    services.prometheus.scrapeConfigs = [
      {
        job_name = "restic-tower";
        scrape_interval = "5s";
        static_configs = [ { targets = [ "tower:8000" ]; } ];
      }
    ];
  }
  (lib.custom.mkResticBackup ({
    name = "remote-tower-backup";
    passwordFile = "${config.sops.secrets.resticThinkTowerRepo.path}";
    repositoryFile = "${config.sops.secrets.resticThinkTowerURL.path}";
    healthchecks = mkResticHealthcheckCommands healthcheck-restic-tower;
    paths = resticPaths;
    timerConfig = resticTimerConfig;
  }))
  (lib.custom.mkResticBackup ({
    name = "remote-ugreen-backup";
    passwordFile = "${config.sops.secrets.resticThinkUgreenRepo.path}";
    repositoryFile = "${config.sops.secrets.resticThinkUgreenURL.path}";
    healthchecks = mkResticHealthcheckCommands healthcheck-restic-ugreen;
    paths = resticPaths;
    timerConfig = resticTimerConfig;
  }))
  (lib.custom.mkResticBackup ({
    name = "remote-borgbase-backup";
    passwordFile = "${config.sops.secrets.resticThinkBorgbaseRepo.path}";
    repositoryFile = "${config.sops.secrets.resticThinkBorgbaseURL.path}";
    healthchecks = mkResticHealthcheckCommands healthcheck-restic-borgbase;
    paths = resticPaths;
    timerConfig = resticTimerConfig;
  }))
]
