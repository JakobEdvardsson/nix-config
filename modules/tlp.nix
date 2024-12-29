{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.tlp;
in
{
  options.lab.tlp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable TLP for power management.";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_MIN_PERF_ON_AC = "0";
        CPU_MAX_PERF_ON_AC = "100";
        CPU_MIN_PERF_ON_BAT = "0";
        CPU_MAX_PERF_ON_BAT = "20";
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "off";
        START_CHARGE_THRESH_BAT0 = "40";
        STOP_CHARGE_THRESH_BAT0 = "80";
      };
      description = "Settings for TLP power management.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tlp.enable = true;
    services.tlp.settings = cfg.settings;
  };
}
