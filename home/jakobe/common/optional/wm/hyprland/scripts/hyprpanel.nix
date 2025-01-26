# - ## Hyprpanel
#- 
#- Quick scripts to toggle, reload, hide & show hyprpanel.
#-
#- - `hyprpanel-toggle` - Toggle hyprpanel (hide/show).
#- - `hyprpanel-show` - Show hyprpanel.
#- - `hyprpanel-hide` - Hide hyprpanel.
#- - `hyprpanel-reload` - Reload hyprpanel.
{ pkgs, ... }:
let
  hyprpanel-toggle = pkgs.writeShellScriptBin "hyprpanel-toggle" ''
    hyprpanel -t bar-0
    hyprpanel -t bar-1
    hyprpanel -t bar-2
    hyprpanel -t bar-3
  '';

  hyprpanel-hide = pkgs.writeShellScriptBin "hyprpanel-hide" ''
    status=$(hyprpanel isWindowVisible bar-0)
    if [[ $status == "true" ]]; then
      hyprpanel -t bar-0
    fi
    status=$(hyprpanel isWindowVisible bar-1)
    if [[ $status == "true" ]]; then
      hyprpanel -t bar-1
    fi
  '';

  hyprpanel-show = pkgs.writeShellScriptBin "hyprpanel-show" ''
    status=$(hyprpanel isWindowVisible bar-0)
    if [[ $status == "false" ]]; then
      hyprpanel -t bar-0
    fi
    status=$(hyprpanel isWindowVisible bar-1)
    if [[ $status == "false" ]]; then
      hyprpanel -t bar-1
    fi
  '';

  hyprpanel-reload = pkgs.writeShellScriptBin "hyprpanel-reload" ''
    [ $(pgrep "ags") ] && pkill ags
    hyprctl dispatch exec hyprpanel
  '';
in {
  home.packages =
    [ hyprpanel-toggle hyprpanel-reload hyprpanel-hide hyprpanel-show ];
}
