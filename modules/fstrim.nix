{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.fstrim;
in
{
  options.lab.fstrim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable or disable the fstrim service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.fstrim.enable = true;
  };
}
