{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customHome.hypridle;
in
{
  options.customHome.hypridle = {
    enable = lib.mkEnableOption "Enable hypridle as the idle state manager for Wayland.";

    lock-screen.enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable lock-screen for hypridle";
    };
    monitor-off.enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable monitor-off for hypridle";
    };
    suspend.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable suspend for hypridle";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        # Dynamically generate listener based on options
        listener = lib.concatLists [
          (
            if cfg.lock-screen.enable then
              [
                {
                  timeout = 300;
                  on-timeout = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
                }
              ]
            else
              [ ]
          )
          (
            if cfg.monitor-off.enable then
              [
                {
                  timeout = 450;
                  on-timeout = "hyprctl dispatch dpms off";
                  on-resume = "hyprctl dispatch dpms on";
                }
              ]
            else
              [ ]
          )
          (
            if cfg.suspend.enable then
              [
                {
                  timeout = 600;
                  on-timeout = "systemctl suspend";
                }
              ]
            else
              [ ]
          )
        ];
      };
    };
  };
}
