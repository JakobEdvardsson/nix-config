{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./config
    ./scripts
    ../waybar
  ];
  # required packages for Hyprland
  home.packages = with pkgs; [
    kitty
    rofi-wayland
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ]; # fix for https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
      # TODO:(hyprland) experiment with whether this is required.
      # Same as default, but stop the graphical session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings = {
      # Monitor, more at the bottom of this file:

      source = [
        "./monitor.conf"
      ];

      #
      # ========== Environment Vars ==========
      #
      env = [
        "NIXOS_OZONE_WL, 1" # for ozone-based and electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND, 1" # for firefox to run on wayland
        "MOZ_WEBRENDER, 1" # for firefox to run on wayland
        "XDG_SESSION_TYPE,wayland"
        "WLR_NO_HARDWARE_CURSORS,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "QT_QPA_PLATFORM,wayland"
      ];

    };
  };
  xdg = {
    configFile = {
      "hypr/monitor.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${config.hostSpec.home}/nix-config/home/jakobe/common/optional/hyprland/config/monitors/${config.hostSpec.hostName}.conf";
    };
  };
}
