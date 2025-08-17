{
  pkgs,
  config,
  lib,
  ...
}:
let
  service = "restic";
  cfg = config.homelab.services.${service};
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
  };
  config = (
    lib.mkIf cfg.enable {
      services.restic.backups = {
        remote-tower-backup = {
          initialize = true;
          passwordFile = "/etc/nixos/secrets/restic-password";
          paths = [
            "/home"
          ];
          repository = "http://jakob:hunter2@tower:8000/mini-pc";
          timerConfig = {
            OnCalendar = "00:05";
            RandomizedDelaySec = "5h";
          };
        };
      };
    }
  );
}
