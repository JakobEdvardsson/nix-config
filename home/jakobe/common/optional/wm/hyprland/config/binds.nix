#NOTE: Actions prepended with `hy3;` are specific to the hy3 hyprland plugin
{
  config,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$shiftMod" = "SUPER_SHIFT";
    # config.home.sessionVariable are defined in /home/jakobe/common/core/default.nix
    bind =
      [
        "$mod, D, exec, pkill rofi || ${pkgs.rofi-wayland}/bin/rofi -show drun -modi drun,filebrowser,run,window"
        "$mod, V, exec, pkill rofi || nvidia-offload ${pkgs.rofi-wayland}/bin/rofi -show drun -modi drun,filebrowser,run,window"

        "$mod, Return, exec, ${config.home.sessionVariables.TERMINAL}" # Launch terminal
        "$mod, T, exec, ${config.home.sessionVariables.FILES}" # Launch file manager"
        "$mod, W, exec, ${config.home.sessionVariables.BROWSER}" # Launch browser

        "CTRL ALT, Delete, exec, hyprctl dispatch exit 0"
        "$mod, Q, killactive,"
        "$mod SHIFT, Q, exec, kill-active-process"
        "$mod, F, fullscreen"
        "$mod SHIFT, F, togglefloating,"
        "$mod ALT, F, exec, hyprctl dispatch workspaceopt allfloat"

        "$shiftMod,L, exec, ${pkgs.hyprlock}/bin/hyprlock" # Lock
        "$shiftMod,P, exec, powermenu" # Powermenu
        "$mod,C, exec, quickmenu" # Quickmenu

        # Resize windows
        "$mod SHIFT, left, resizeactive,-50 0"
        "$mod SHIFT, right, resizeactive,50 0"
        "$mod SHIFT, up, resizeactive,0 -50"
        "$mod SHIFT, down, resizeactive,0 50"

        # Move windows
        "$mod CTRL, left, movewindow, l"
        "$mod CTRL, right, movewindow, r"
        "$mod CTRL, up, movewindow, u"
        "$mod CTRL, down, movewindow, d"

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Workspaces related
        "$mod, tab, workspace, m+1"
        "$mod SHIFT, tab, workspace, m-1"

        # Screenshot
        # Screenshot a window
        "$mod, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m window"
        # Screenshot a monitor
        ",PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m output"
        # Screenshot a region
        "SHIFT, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m region"

        # Scroll through existing workspaces with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        "$mod, period, workspace, e+1"
        "$mod, comma, workspace, e-1"

        # Custom
        "$shiftMod,E, exec, emoji-picker" # Emoji picker with wofi
        "$shiftMod,N, exec, night-shift" # Toggle night shift

      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
          in
          [
            "$mod,code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT,code:1${toString i}, movetoworkspace, ${toString ws}"
            "$mod CTRL, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
          ]
        ) 10
      ));

    bindm = [
      "$mod,mouse:272, movewindow" # Move Window (mouse)
      "$mod, mouse:273, resizewindow" # Resize Window (mouse)
    ];

    bindl = [
      ",XF86AudioMute, exec, sound-toggle" # Toggle Mute
      ",XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause" # Play/Pause Song
      ",XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next" # Next Song
      ",XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous" # Previous Song
      ",switch:Lid Switch, exec, ${pkgs.hyprlock}/bin/hyprlock" # Lock when closing Lid
    ];

    bindle = [
      ",XF86AudioRaiseVolume, exec, sound-up" # Sound Up
      ",XF86AudioLowerVolume, exec, sound-down" # Sound Down
      ",XF86MonBrightnessUp, exec, brightness-up" # Brightness Up
      ",XF86MonBrightnessDown, exec, brightness-down" # Brightness Down
    ];
  };
}
