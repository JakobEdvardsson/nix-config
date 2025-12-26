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
        asList (config.services.${service}.mediaLocation or null)
        ++ asList (config.services.${service}.dataDir or null)
        ++ asList (config.services.${service}.configDir or null)
        ++ asList (config.services.${service}.location or null);
  };
  homepage.name = lib.mkOption {
    type = lib.types.str;
    default = homepage.name or lib.strings.toSentenceCase service;
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
