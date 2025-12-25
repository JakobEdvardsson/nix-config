{
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.xfce;
in
{
  options.customOption.xfce = {
    enable = lib.mkEnableOption "Enable xfce";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.xfce.enable = true;
    services.xserver.desktopManager.xfce.enableScreensaver = false;
  };
}
