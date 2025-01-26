{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hyprland
    ./waybar
    ./rofi-wayland
  ];
}
