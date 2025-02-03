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
    ./hyprlock
    ./hypridle
    ./swaync
    ./polkit
  ];
}
