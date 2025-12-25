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
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
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
    })
    (lib.mkIf config.homelab.services.enable {
      assertions = [
        {
          assertion = cfg.enable;
          message = "homelab.services.enable requires homelab.enable to be set to true.";
        }
      ];

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      security.acme = {
        acceptTerms = true;
        defaults.email = config.hostSpec.email;
        certs.${config.homelab.baseDomain} = {
          reloadServices = [ "caddy.service" ];
          domain = "${config.homelab.baseDomain}";
          extraDomainNames = [ "*.${config.homelab.baseDomain}" ];
          dnsProvider = "cloudflare";
          dnsResolver = "1.1.1.1:53";
          dnsPropagationCheck = true;
          group = config.services.caddy.group;
          environmentFile = config.homelab.cloudflare.dnsCredentialsFile;
        };
      };

      services.caddy = {
        enable = true;
        globalConfig = ''
          auto_https off
        '';
        # virtualHosts = {
        #   "http://${config.homelab.baseDomain}" = {
        #     extraConfig = ''
        #       redir https://{host}{uri}
        #     '';
        #   };
        #   "http://*.${config.homelab.baseDomain}" = {
        #     extraConfig = ''
        #       redir https://{host}{uri}
        #     '';
        #   };
        #};
      };
    })
  ];
}
