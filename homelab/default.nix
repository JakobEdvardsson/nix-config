{ lib, config, ... }:
let
  cfg = config.homelab;
in
{
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
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
  };
}
