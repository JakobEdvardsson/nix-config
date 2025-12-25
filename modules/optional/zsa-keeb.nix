{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.zsa-keeb;
in
{
  options.customOption.zsa-keeb = {
    enable = lib.mkEnableOption "Enable zsa-keeb";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.zsa.enable = true;
    hardware.keyboard.qmk.enable = true;
    environment.systemPackages = with pkgs; [
      keymapp
      qmk
    ];
  };
}
