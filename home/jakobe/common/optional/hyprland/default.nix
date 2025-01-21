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
    ./waybar
  ];
  # required packages for Hyprland
  home.packages = with pkgs; [
    kitty

    rofi-wayland
    playerctl # manage audio
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

      #
      # ========== Monitor ==========
      #
      # parse the monitor spec defined in nix-config/home/<user>/<host>.nix
      /*
        monitor = (
          map (
            m:
            "${m.name},${
              if m.enabled then
                "${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},1,transform,${toString m.transform},vrr,${toString m.vrr}"
              else
                "disable"
            }"
          ) (config.monitors)
        );
      */

      workspace = [
        "1, monitor:DP-1, default:true, persistent:true"
        "2, monitor:DP-1, default:true"
        "3, monitor:DP-1, default:true"
        "4, monitor:DP-1, default:true"
        "5, monitor:DP-1, default:true"
        "6, monitor:DP-1, default:true"
        "7, monitor:DP-1, default:true"
        "8, monitor:DP-2, default:true, persistent:true"
        "9, monitor:HDMI-A-1, default:true, persistent:true"
        "0, monitor:DP-3, default:true, persistent:true"
      ];

      #
      # ========== Layer Rules ==========
      #
      layer = [
        #"blur, rofi"
        #"ignorezero, rofi"
        #"ignorezero, logout_dialog"

      ];
      #
      # ========== Window Rules ==========
      #
      windowrule = [
        # Dialogs
        "float, title:^(Open File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Open Folder)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Library)(.*)$"
        "float, title:^(Accounts)(.*)$"
      ];
      windowrulev2 = [
        "float, class:^(galculator)$"
        "float, class:^(waypaper)$"
        "float, class:^(keymapp)$"

        #
        # ========== Always opaque ==========
        #
        "opaque, class:^([Gg]imp)$"
        "opaque, class:^([Ff]lameshot)$"
        "opaque, class:^([Ii]nkscape)$"
        "opaque, class:^([Bb]lender)$"
        "opaque, class:^([Oo][Bb][Ss])$"
        "opaque, class:^([Ss]team)$"
        "opaque, class:^([Ss]team_app_*)$"
        "opaque, class:^([Vv]lc)$"

        # Remove transparency from video
        "opaque, title:^(Netflix)(.*)$"
        "opaque, title:^(.*YouTube.*)$"
        "opaque, title:^(Picture-in-Picture)$"
        #
        # ========== Scratch rules ==========
        #
        #"size 80% 85%, workspace:^(special:special)$"
        #"center, workspace:^(special:special)$"

        #
        # ========== Steam rules ==========
        #
        "stayfocused, title:^()$,class:^([Ss]team)$"
        "minsize 1 1, title:^()$,class:^([Ss]team)$"
        "immediate, class:^([Ss]team_app_*)$"
        #"workspace 7, class:^([Ss]team_app_*)$"
        #"monitor 0, class:^([Ss]team_app_*)$"

        #
        # ========== Fameshot rules ==========
        #
        # flameshot currently doesn't have great wayland support so needs some tweaks
        #"rounding 0, class:^([Ff]lameshot)$"
        #"noborder, class:^([Ff]lameshot)$"
        #"float, class:^([Ff]lameshot)$"
        #"move 0 0, class:^([Ff]lameshot)$"
        #"suppressevent fullscreen, class:^([Ff]lameshot)$"
        # "monitor:DP-1, ${flameshot}"

        #
        # ========== Workspace Assignments ==========
        #
        "workspace 8, class:^(virt-manager)$"
        "workspace 8, class:^(obsidian)$"
        "workspace 9, class:^(brave-browser)$"
        "workspace 9, class:^(signal)$"
        "workspace 9, class:^(org.telegram.desktop)$"
        "workspace 9, class:^(discord)$"
        "workspace 0, class:^(yubioath-flutter)$"
        "workspace 0, title:^([Ss]potify*)$"
      ];
    };
  };
  xdg = {
    configFile = {
      "hypr/monitor.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.hostSpec.home}/nix-config/home/jakobe/common/optional/hyprland/config/monitors/${config.hostSpec.hostName}.conf";
    };
  };
}
