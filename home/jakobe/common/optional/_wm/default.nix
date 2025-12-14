{ pkgs, config, lib, ... }: {
  imports = [
    ./hyprland
    ./waybar
    ./rofi
    ./hyprlock
    ./hypridle
    ./swaync
    ./polkit
  ];
}
