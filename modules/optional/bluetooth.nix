{
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.bluetooth;
in
{
  options.customOption.bluetooth = {
    enable = lib.mkEnableOption "Enable bluetooth";
  };

  config = lib.mkIf cfg.enable {
    # Bluetooth
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
          };
        };
      };
    };

    services.blueman.enable = true;
  };
}
