{
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.hyprland;
in
{
  imports = [
    #./thunar.nix # file manager
    ./nautilus.nix # file manager
    ./audio.nix # pipewire and cli controls
    ./bluetooth.nix # bluetooth and blueman
    #TODO: add a display manager
  ];

  options.customOption.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland";
  };

  config = lib.mkIf cfg.enable {
    customOption.audio.enable = true;
    customOption.bluetooth.enable = true;
    customOption.nautilus.enable = true;

    programs.hyprland = {
      enable = true;
    };
  };
}
