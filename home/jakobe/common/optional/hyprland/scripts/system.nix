# - ## System
#- 
#- Usefull quick scripts
#-
#- - `powermenu` - Open power dropdown menu. (rofi)
#- - `lock` - Lock the screen. (hyprlock)
{ pkgs, ... }:

let
  powermenu =
    pkgs.writeShellScriptBin "powermenu"
      # bash
      ''
        if pgrep rofi; then
        	pkill rofi
        # if pgrep tofi; then
        #   pkill tofi
        else
          options=(
            "󰌾 Lock"
            "󰍃 Logout"
            " Suspend"
            "󰑐 Reboot"
            "󰿅 Shutdown"
          )

          selected=$(printf '%s\n' "''${options[@]}" | rofi -dmenu -p " Powermenu")
          # selected=$(printf '%s\n' "''${options[@]}" | tofi --prompt-text "> ")
          selected=''${selected:2}

          case $selected in
            "Lock")
              ${pkgs.hyprlock}/bin/hyprlock
              ;;
            "Logout")
              hyprctl dispatch exit
              ;;
            "Suspend")
              systemctl suspend
              ;;
            "Reboot")
              systemctl reboot
              ;;
            "Shutdown")
              systemctl poweroff
              ;;
          esac
        fi
      '';

  quickmenu =
    pkgs.writeShellScriptBin "quickmenu"
      # bash
      ''
        if pgrep rofi; then
        	pkill rofi
        # if pgrep tofi; then
        #   pkill tofi
        else
          options=(
            "󰅶 Caffeine"
            "󰖔 Night-shift"
            " Nixy"
            "󰈊 Hyprpicker"
          )

          selected=$(printf '%s\n' "''${options[@]}" | rofi -dmenu -p " Quickmenu" )
          # selected=$(printf '%s\n' "''${options[@]}" | tofi --prompt-text "> ")
          selected=''${selected:2}

          case $selected in
            "Caffeine")
              caffeine
              ;;
            "Night-shift")
              night-shift
              ;;
            "Nixy")
              kitty zsh -c nixy
              ;;
            "Hyprpicker")
              sleep 0.2 && ${pkgs.hyprpicker}/bin/hyprpicker -a
              ;;
          esac
        fi
      '';

  lock =
    pkgs.writeShellScriptBin "lock"
      # bash
      ''
        ${pkgs.hyprlock}/bin/hyprlock
      '';

in
{
  home.packages = [
    powermenu
    lock
    quickmenu
  ];
}
