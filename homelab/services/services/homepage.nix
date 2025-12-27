{ config, lib, ... }:
let
  service = "homepage";
  nixosService = "homepage-dashboard";
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
        show = false;
      };
    })
    // {
      allowedHosts = lib.mkOption {
        type = lib.types.str;
        default = "localhost:8082,127.0.0.1:8082,0.0.0.0:8082,${cfg.url}";
      };
      glancesNetworkInterface = lib.mkOption {
        type = lib.types.str;
        default = "enp2s0";
      };

      external = lib.mkOption {
        default = [ ];
        type = lib.types.listOf (
          lib.types.attrsOf (
            lib.types.submodule {
              options = {
                description = lib.mkOption { type = lib.types.str; };
                href = lib.mkOption { type = lib.types.str; };
                siteMonitor = lib.mkOption { type = lib.types.str; };
                icon = lib.mkOption { type = lib.types.str; };
                category = lib.mkOption { type = lib.types.str; };
              };
            }
          )
        );
      };
    };
  config = lib.mkIf cfg.enable {
    services.glances.enable = true;
    services.${nixosService} =
      let
        homepageEnabledServices = lib.attrsets.filterAttrs (
          name: value: value ? enable && value.enable && value ? homepage && value.homepage.show
        ) homelab.services;
        homelabCategories = lib.lists.unique (
          lib.attrsets.mapAttrsToList (_: value: value.homepage.category) homepageEnabledServices
        );
        externalCategories = lib.lists.unique (
          lib.lists.concatMap (
            entry: lib.attrsets.mapAttrsToList (_: value: value.category) entry
          ) cfg.external
        );
        homepageCategories = lib.lists.unique (homelabCategories ++ externalCategories);
        homepageServices =
          cat: lib.attrsets.filterAttrs (_: value: value.homepage.category == cat) homepageEnabledServices;
        externalServices =
          cat:
          lib.lists.filter (x: x != null) (
            lib.lists.concatMap (
              entry:
              lib.attrsets.mapAttrsToList (
                name: value:
                if value.category == cat then
                  { "${name}" = lib.attrsets.removeAttrs value [ "category" ]; }
                else
                  null
              ) entry
            ) cfg.external
          );
      in
      {
        enable = true;
        allowedHosts = cfg.allowedHosts;
        settings = {
          layout = [
            {
              Glances = {
                header = false;
                style = "row";
                columns = 4;
              };
            }
          ]
          ++ lib.lists.forEach homepageCategories (cat: {
            "${cat}" = {
              header = true;
              style = "column";
            };
          });
          headerStyle = "clean";
          statusStyle = "dot";
          hideVersion = "true";
        };
        services =
          lib.lists.forEach homepageCategories (cat: {
            "${cat}" =
              lib.attrsets.mapAttrsToList (name: value: {
                "${value.homepage.name}" = {
                  icon = value.homepage.icon;
                  description = value.homepage.description;
                  href = "https://${value.url}";
                  siteMonitor = "https://${value.url}";
                };
              }) (homepageServices "${cat}")
              ++ externalServices "${cat}";
          })
          ++ [
            {
              Glances =
                let
                  port = toString config.services.glances.port;
                in
                [
                  {
                    Info = {
                      widget = {
                        type = "glances";
                        url = "http://localhost:${port}";
                        metric = "info";
                        chart = false;
                        version = 4;
                      };
                    };
                  }
                  {
                    "CPU Temp" = {
                      widget = {
                        type = "glances";
                        url = "http://localhost:${port}";
                        metric = "sensor:Package id 0";
                        chart = false;
                        version = 4;
                      };
                    };
                  }
                  {
                    Processes = {
                      widget = {
                        type = "glances";
                        url = "http://localhost:${port}";
                        metric = "process";
                        chart = false;
                        version = 4;
                      };
                    };
                  }
                  {
                    Network = {
                      widget = {
                        type = "glances";
                        url = "http://localhost:${port}";
                        metric = "network:${cfg.glancesNetworkInterface}";
                        chart = false;
                        version = 4;
                      };
                    };
                  }
                ];
            }
          ];
      };
    services.caddy.virtualHosts."${cfg.url}" = lib.mkIf homelab.caddy.enable (
      lib.custom.mkCaddyReverseProxy {
        proxyTo = "http://127.0.0.1:${toString config.services.${nixosService}.listenPort}";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
