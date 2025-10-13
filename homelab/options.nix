{ lib, service, config, homelab, homepage ? { } }: {
  enable = lib.mkEnableOption { description = "Enable ${service}"; };
  url = lib.mkOption {
    type = lib.types.str;
    default = "${service}.${homelab.baseDomain}";
  };
  dataDir = lib.mkOption {
    type = lib.types.str;
    default = "/var/lib/${service}";
  };
  backupDataDir = lib.mkOption {
    type = lib.types.bool;
    description = "Whether the dataDir should be included in backups.";
    default = true;
  };
  homepage.name = lib.mkOption {
    type = lib.types.str;
    default = lib.strings.toSentenceCase service;
  };
  homepage.description = lib.mkOption {
    type = lib.types.str;
    default = homepage.description;
  };
  homepage.icon = lib.mkOption {
    type = lib.types.str;
    default = homepage.icon or "${service}.svg";
  };
  homepage.category = lib.mkOption {
    type = lib.types.str;
    default = homepage.category;
  };
}
