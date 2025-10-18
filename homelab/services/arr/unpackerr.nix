{ lib, config, pkgs, ... }:
let
  service = "unpackerr";
  homelab = config.homelab;
  cfg = config.homelab.services."${service}";
  optionsFn = import ../../options.nix;

  # Supported *arr services we can integrate with. Extend as needed.
  arrs = [ "sonarr" "radarr" "lidarr" "readarr" ];

  # Build environment attributes for enabled integrations.
  envAttrs = builtins.listToAttrs (lib.concatMap (arr:
    let
      sub = (cfg.${arr} or { });
      arrService = (config.homelab.services.${arr} or { });
      # If sub.enable is null follow the referenced service enable flag.
      arrEnabled = if (sub.enable or null) == null then
        (arrService.enable or false)
      else
        sub.enable;
      upper = lib.toUpper arr;
      # URL
    in (lib.optional arrEnabled {
      name = "UN_${upper}_0_URL";
      value = sub.url;
    })
    # API key
    ++ (lib.optional (arrEnabled && (sub.apiKey or "") != "") {
      name = "UN_${upper}_0_API_KEY";
      value = sub.apiKey;
    })
    # Optional path (from dataDir) -> UN_<ARR>_0_PATHS_0
    ++ (lib.optional (arrEnabled && (sub.dataDir or "") != "") {
      name = "UN_${upper}_0_PATHS_0";
      value = sub.dataDir;
    })) arrs);
in {
  ########################################
  # Options
  ########################################
  options.homelab.services.${service} = (optionsFn {
    inherit lib service config homelab;
    homepage = {
      description =
        "Automatically extracts archives reported by *arr applications";
      category = "Arr";
    };
  }) // (lib.genAttrs arrs (arr:
    let upper = lib.toUpper arr;
    in {
      enable = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        # null -> follow homelab.services.${arr}.enable when available.
        default = null;
        description =
          "Enable integration with ${arr}. Null follows ${arr}'s enable flag.";
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = (config.homelab.services.${arr}.url or "http://${arr}.local");
        description = "Base URL for ${arr}. Populates UN_${upper}_0_URL.";
      };
      apiKey = lib.mkOption {
        type = lib.types.str;
        default =
          ""; # User supplies explicitly; we do not couple to other secret paths automatically.
        example = "abcdef0123456789abcdef0123456789";
        description =
          "API key for ${arr}. Populates UN_${upper}_0_API_KEY when non-empty.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/mnt/data";
        description =
          "Path to use for ${arr} data storage. Populates UN_${upper}_0_PATHS_0 when set.";
      };
    }));

  ########################################
  # Configuration
  ########################################
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      systemd.services.${service} = {
        description = "Unpackerr Service";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.unpackerr}/bin/unpackerr";
          Restart = "on-failure";
          DynamicUser = true;
          StateDirectory = service;
          WorkingDirectory = "/var/lib/${service}";
          # Hardening
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictNamespaces = true;
          RemoveIPC = true;
          CapabilityBoundingSet = "";
          AmbientCapabilities = "";
        };
        environment = envAttrs;
      };
    }
    {
      # Expose via Caddy similar to other services (unpackerr listens on 5656 by default)
      services.caddy.virtualHosts."${cfg.url}" = {
        useACMEHost = homelab.baseDomain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:5656
        '';
      };
    }
  ]);
}
