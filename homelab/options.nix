{
  lib,
  service,
  config,
  homelab,
  homepage ? { },
  dataDirs ? null,
}:
let
  # Normalize a nullable value (str or [str ...]) into a list of strings.
  serviceConfig = config.services.${service} or { };
  asList =
    v:
    if v == null then
      [ ]
    else if builtins.isList v then
      v
    else
      [ v ];
in
{
  enable = lib.mkEnableOption { description = "Enable ${service}"; };
  url = lib.mkOption {
    type = lib.types.str;
    default = "${service}.${homelab.baseDomain}";
  };
  dataDirs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default =
      if dataDirs != null then
        asList dataDirs
      else
        asList (serviceConfig.mediaLocation or null)
        ++ asList (serviceConfig.dataDir or null)
        ++ asList (serviceConfig.configDir or null)
        ++ asList (serviceConfig.location or null);
  };
  homepage = {
    name = lib.mkOption {
      type = lib.types.str;
      default = homepage.name or (lib.strings.toSentenceCase service);
    };
    description = lib.mkOption {
      type = lib.types.str;
      default = homepage.description or "";
    };
    show = lib.mkOption {
      type = lib.types.bool;
      default = homepage.show or true;
      description = "Show this service on the homepage dashboard.";
    };
    icon = lib.mkOption {
      type = lib.types.str;
      default = homepage.icon or "${service}";
    };
    category = lib.mkOption {
      type = lib.types.str;
      default = homepage.category or "Services";
    };
  };
}
