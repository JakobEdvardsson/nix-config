{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.customOption.comin;
in
{
  imports = [ inputs.comin.nixosModules.comin ];

  options.customOption.comin = {
    enable = lib.mkEnableOption "Enable comin, auto pulls config from Github";
  };

  config = lib.mkIf cfg.enable (
    let
      cominPkg = config.services.comin.package;
      scriptName = "comin-reboot-if-needed";
      rebootScript = pkgs.writeShellScriptBin scriptName ''
        if ${cominPkg}/bin/comin status | ${pkgs.ripgrep}/bin/rg -q 'Need to reboot: yes'; then
          if ! ${pkgs.coreutils}/bin/sleep 5; then
            echo "Warning: sleep failed, proceeding to reboot anyway" >&2
          fi
          ${pkgs.systemd}/bin/systemctl reboot
        fi
      '';
    in
    {
      sops.secrets = {
        githubCominAccessToken = { };
      };

      services.comin = {
        enable = true;
        exporter.listen_address = "127.0.0.1";
        remotes = [
          {
            name = "origin";
            url = "https://github.com/jakobedvardsson/nix-config.git";
            branches.main.name = "main";
            auth.access_token_path = config.sops.secrets.githubCominAccessToken.path;
          }
        ];
      };

      systemd.services."${scriptName}" = {
        description = "Reboot when comin reports a pending reboot";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${rebootScript}/bin/${scriptName}";
        };
        after = [ "comin.service" ];
        requires = [ "comin.service" ];
      };

      systemd.timers."${scriptName}" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "04:00";
          Persistent = true;
        };
      };
    }
  );
}
