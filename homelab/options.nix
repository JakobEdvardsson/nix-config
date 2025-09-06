{ lib, service, homelab, cfg, dataDir, homepage ? { } }: {
  enable = lib.mkEnableOption { description = "Enable ${service}"; };
  url = lib.mkOption {
    type = lib.types.str;
    default = "${service}.${homelab.baseDomain}";
  };
  dataDirs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = lib.optional (cfg ? mediaLocation && cfg.mediaLocation != null)
      cfg.mediaLocation
      ++ lib.optional (cfg ? dataDir && cfg.dataDir != null) cfg.dataDir
      ++ lib.optional (cfg ? location && cfg.location != null) cfg.location;
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
