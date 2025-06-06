{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.deploy;
  pubKeys = lib.filesystem.listFilesRecursive ./primary/keys;
in
{
  options.customOption.deploy = {
    enable = lib.mkEnableOption "Enable deploy user";
  };

  config = lib.mkIf cfg.enable {
    users.groups.deploy = { };

    users.users.deploy = {
      isNormalUser = true;
      group = "deploy";
      home = "/home/deploy";
      password = null;
      createHome = true;
      openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
    };

    services.openssh.enable = true;

    services.openssh.extraConfig = ''
      Match User deploy
        PasswordAuthentication no
        PermitTTY no
        AllowTcpForwarding no
        X11Forwarding no
    '';

    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = true;

    security.sudo.extraRules = [
      {
        groups = [ "deploy" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemd-run";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/nix/store/*/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-store";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = [ "NOPASSWD" ];
          }
          {
            command = ''/bin/sh -c "readlink -e /nix/var/nix/profiles/system || readlink -e /run/current-system"'';
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-collect-garbage";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
