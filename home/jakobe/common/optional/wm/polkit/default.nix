{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customHome.polkit;
in
{

  options.customHome.polkit = {
    enable = lib.mkEnableOption "Enable polkit for Wayland.";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit.Description = "polkit-gnome-authentication-agent-1";

      Install = {
        WantedBy = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    home.packages = [ pkgs.polkit_gnome ];
  };
}
