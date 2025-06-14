{ lib, config, ... }:
let
  cfg = config.homelab;
in
{
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    mounts.slow = lib.mkOption {
      default = "/mnt/slow";
      type = lib.types.path;
      description = ''
        Path to the 'slow' mount
      '';
    };
    mounts.fast = lib.mkOption {
      default = "/mnt/fast";
      type = lib.types.path;
      description = ''
        Path to the 'fast' mount
      '';
    };
    mounts.config = lib.mkOption {
      default = "/appdata";
      type = lib.types.path;
      description = ''
        Path to the service configuration files
      '';
    };
    user = lib.mkOption {
      default = "media";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
      #apply = old: builtins.toString config.users.users."${old}".uid;
    };
    group = lib.mkOption {
      default = "media";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
      #apply = old: builtins.toString config.users.groups."${old}".gid;
    };
    timeZone = lib.mkOption {
      default = "Europe/Stockholm";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };
    baseDomain = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };
    cloudflare.dnsCredentialsFile = lib.mkOption { type = lib.types.path; };
  };
  imports = [
    ./services
    # ./samba
    # ./networks
    # ./motd
  ];
  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = {
        gid = 993;
      };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };
  };
}
