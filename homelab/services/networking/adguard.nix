{ config, lib, ... }:
let
  service = "adguard";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
  optionsFn = import ../../options.nix;
in
{
  options.homelab.services.${service} =
    (optionsFn {
      inherit
        lib
        service
        config
        homelab
        ;
      homepage = {
        description = "Local DNS server";
        category = "Networking";
      };
    })
    // {
      rewrites = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              domain = lib.mkOption { type = lib.types.str; };
              answer = lib.mkOption { type = lib.types.str; };
            };
          }
        );
        default = [ ];
      };
    };
  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      port = 3000;

      settings = {
        dns = {
          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns10.quad9.net/dns-query"
          ];
        };

        filtering = {
          rewrites = cfg.rewrites;
          protection_enabled = true;
          filtering_enabled = true;

          parental_enabled = false; # Parental control-based DNS requests filtering.
          safe_search = {
            enabled = true; # Enforcing "Safe search" option for search engines, when possible.
            bing = true;
            duckduckgo = true;
            ecosia = true;
            google = true;
            pixabay = true;
            yandex = true;
            youtube = false;
          };
        };

        # The following notation uses map
        # to not have to manually create {enabled = true; url = "";} for every filter
        # This is, however, fully optional
        filters =
          map
            (url: {
              enabled = true;
              url = url;
            })
            [
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
            ];
      };
    };

    networking = {
      firewall = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:3000";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
