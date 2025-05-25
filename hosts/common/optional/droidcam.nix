{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customOption.droidcam;
in
{

  options.customOption.droidcam = {
    enable = lib.mkEnableOption "Enable droidcam";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [
      "v4l2loopback" # Webcam loopback
    ];
    boot.extraModulePackages = [
      pkgs.linuxPackages_6_12.v4l2loopback # Webcam loopback
    ];

    environment.systemPackages = with pkgs; [
      obs-studio
      droidcam
      # Webcam packages
      v4l-utils
      android-tools
      adb-sync
    ];
  };
}
