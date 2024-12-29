{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.bluetooth;
in
{
  options.lab.bluetooth = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable Bluetooth support";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;
  };
}
