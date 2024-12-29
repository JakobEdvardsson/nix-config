{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.localization;
in
{
  options.lab.localization = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable custom localization configuration.";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Stockholm";
      description = "The time zone for the system.";
    };

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "The default locale for the system.";
    };

    extraLocaleSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        LC_ADDRESS = "sv_SE.UTF-8";
        LC_IDENTIFICATION = "sv_SE.UTF-8";
        LC_MEASUREMENT = "sv_SE.UTF-8";
        LC_MONETARY = "sv_SE.UTF-8";
        LC_NAME = "sv_SE.UTF-8";
        LC_NUMERIC = "sv_SE.UTF-8";
        LC_PAPER = "sv_SE.UTF-8";
        LC_TELEPHONE = "sv_SE.UTF-8";
        LC_TIME = "sv_SE.UTF-8";
      };
      description = "Additional locale settings for the system.";
    };

    consoleKeyMap = lib.mkOption {
      type = lib.types.str;
      default = "sv-latin1";
      description = "The key map for the console.";
    };

    xserverEnable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable the X server.";
    };

    xserverKeyMap = lib.mkOption {
      type = lib.types.str;
      default = "se";
      description = "The key map layout for X server.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set the time zone
    time.timeZone = cfg.timeZone;

    # Set the default locale
    i18n.defaultLocale = cfg.defaultLocale;

    # Set extra locale settings
    i18n.extraLocaleSettings = cfg.extraLocaleSettings;

    # Set the console key map
    console.keyMap = cfg.consoleKeyMap;

    # Configure X server settings if enabled
    services.xserver.enable = cfg.xserverEnable;
    services.xserver.xkb.layout = cfg.xserverKeyMap;
    services.xserver.xkb.variant = "";
  };
}
