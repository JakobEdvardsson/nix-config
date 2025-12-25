{ config, lib, ... }:
let
  cfg = config.homelab;
in
{
  options.homelab.caddy = {
    enable = lib.mkEnableOption "Enable Caddy and ACME for homelab";
    virtualHosts = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra Caddy virtualHosts entries to merge into services.caddy.virtualHosts.";
    };
  };

  config = lib.mkIf cfg.caddy.enable {
    sops.secrets = {
      cloudflareDnsApiCredentials = { };
      wireguardCredentials = { };
    };

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
        environmentFile = config.sops.secrets.cloudflareDnsApiCredentials.path;
      };
    };

    services.caddy = {
      enable = true;
      globalConfig = ''
        auto_https off
      '';
      virtualHosts = cfg.caddy.virtualHosts;
    };
  };
}
