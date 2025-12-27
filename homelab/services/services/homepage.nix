{ config, lib, ... }:
let
  service = "homepage-dashboard";
  cfg = config.homelab.services.homepage;
  homelab = config.homelab;
  optionsFn = import ../../options.nix;
in
{
  options.homelab.services.homepage =
    (optionsFn {
      inherit
        lib
        service
        config
        homelab
        ;
      defaultUrl = "homepage.${homelab.baseDomain}";
      homepage = {
        name = "Homepage";
        description = "Homelab dashboard";
        icon = "homepage.svg";
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
    services.${service} = {
      enable = true;
      allowedHosts = cfg.allowedHosts;
      customCSS = ''
        body, html {
          font-family: SF Pro Display, Helvetica, Arial, sans-serif !important;
        }
        .font-medium {
          font-weight: 700 !important;
        }
        .font-light {
          font-weight: 500 !important;
        }
        .font-thin {
          font-weight: 400 !important;
        }
        #information-widgets {
          padding-left: 1.5rem;
          padding-right: 1.5rem;
        }
        div#footer {
          display: none;
        }
        .services-group.basis-full.flex-1.px-1.-my-1 {
          padding-bottom: 3rem;
        };
      '';
      settings = {
        layout = [
          {
            Glances = {
              header = false;
              style = "row";
              columns = 4;
            };
          }
          {
            Arr = {
              header = true;
              style = "column";
            };
          }
          {
            Media = {
              header = true;
              style = "column";
            };
          }
          {
            Services = {
              header = true;
              style = "column";
            };
          }
          {
            External = {
              header = true;
              style = "column";
            };
          }
        ];
        headerStyle = "clean";
        statusStyle = "dot";
        hideVersion = "true";
      };
      services =
        let
          homepageCategories = [
            "Arr"
            "Media"
            "Services"
          ];
          # TODO: Render external
          hl = config.homelab.services;
          homepageServices =
            x:
            (lib.attrsets.filterAttrs (
              name: value: value ? enable && value.enable && value ? homepage && value.homepage.category == x
            ) homelab.services);
        in
        lib.lists.forEach homepageCategories (cat: {
          "${cat}" =
            lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) (homepageServices "${cat}"))
              (x: {
                "${hl.${x}.homepage.name}" = {
                  icon = hl.${x}.homepage.icon;
                  description = hl.${x}.homepage.description;
                  href = "https://${hl.${x}.url}";
                  siteMonitor = "https://${hl.${x}.url}";
                };
              });
        })
        ++ [ { External = cfg.external; } ]
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
        proxyTo = "http://127.0.0.1:${toString config.services.${service}.listenPort}";
        useACMEHost = homelab.baseDomain;
      }
    );
  };
}
