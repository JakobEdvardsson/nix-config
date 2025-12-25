# - ## Nixy
#-
#- Nixy is a simple script that I use to manage my NixOS system. It's a simple script that provides a menu to rebuild, upgrade, update, collect garbage, clean boot menu, etc.
#-
#- - `nixy` - UI wizard to manage the system.
#- - `nixy rebuild` - Rebuild the system.
#- - `nixy ...` - ... see the script for more commands.
{
  pkgs,
  config,
  inputs,
  ...
}:
let
  configDirectory = "${config.hostSpec.home}/nix-config";
  hostname = config.hostSpec.hostName;

  nixy =
    pkgs.writeShellScriptBin "nixy"
      # bash
      ''
        function exec() {
          $@
        }

        function ui(){
          DEFAULT_ICON="󰘳"

          # "icon;name;command"[]
          apps=(
            "󰑓;Rebuild;nixy rebuild"
            "󰦗;Upgrade;nixy upgrade"
            "󰚰;Update;nixy update"
            ";Collect Garbage;nixy gc"
          )

          # Apply default icons if empty:
          for i in "''${!apps[@]}"; do
            apps[i]=$(echo "''${apps[i]}" | sed 's/^;/'$DEFAULT_ICON';/')
          done

          fzf_result=$(printf "%s\n" "''${apps[@]}" | awk -F ';' '{print $1" "$2}' | fzf)
          [[ -z $fzf_result ]] && exit 0
          fzf_result=''${fzf_result/ /;}
          line=$(printf "%s\n" "''${apps[@]}" | grep "$fzf_result")
          command=$(echo "$line" | sed 's/^[^;]*;//;s/^[^;]*;//')

          exec "$command"
          exit 0
        }

        [[ $1 == "" ]] && ui

        if [[ $1 == "rebuild" ]];then
          echo '${configDirectory} ${hostname}'
          nh os switch ${configDirectory} --hostname ${hostname}
        elif [[ $1 == "upgrade" ]];then
          nh os switch ${configDirectory} --hostname ${hostname}
        elif [[ $1 == "update" ]];then
          cd ${configDirectory} && nix flake update
        elif [[ $1 == "gc" ]];then
          cd ${configDirectory} && sudo nix-collect-garbage -d
        elif [[ $1 == "cb" ]];then
          sudo /run/current-system/bin/switch-to-configuration boot
        else
          echo "Unknown argument"
        fi

        read -p "Press enter to exit..."
      '';
in
{
  home.packages = [ nixy ];
}
