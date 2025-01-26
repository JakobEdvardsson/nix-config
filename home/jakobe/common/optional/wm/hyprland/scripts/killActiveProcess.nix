{ pkgs, ... }:
let
  kill-active-process = pkgs.writeShellScriptBin "kill-active-process" ''
    # Get id of an active window
    active_pid=$(hyprctl activewindow | grep -o 'pid: [0-9]*' | cut -d' ' -f2)

    # Close active window
    kill $active_pid
  '';

in
{
  home.packages = [ kill-active-process ];
}
