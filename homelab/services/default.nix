{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = lib.custom.scanPaths ./.;

  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
  };

  config = lib.mkIf config.homelab.services.enable {

    assertions = [
      {
        assertion = config.homelab.enable;
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
  };
}
