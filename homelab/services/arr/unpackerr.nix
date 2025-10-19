{ lib, config, pkgs, ... }:
let
  service = "unpackerr";
  homelab = config.homelab;
  cfg = config.homelab.services.${service};
  optionsFn = import ../../options.nix;

  arrs = [ "sonarr" "radarr" "lidarr" "readarr" ];

in {
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
        default = null;
        description =
          "Enable integration with ${arr}. Null follows ${arr}'s enable flag.";
      };
      url = lib.mkOption {
        type = lib.types.str;
        default = (config.homelab.services.${arr}.url or "http://${arr}.local");
        description = "Base URL for ${arr}. Populates UN_${upper}_0_URL.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "";
        description =
          "Optional path for ${arr}. Populates UN_${upper}_0_PATHS_0.";
      };
    }));

  config = lib.mkIf cfg.enable (let
    enabledArrs = lib.filter (arr:
      let
        sub = cfg.${arr} or { };
        arrService = config.homelab.services.${arr} or { };
        arrEnabled = if (sub.enable or null) == null then
          (arrService.enable or false)
        else
          sub.enable;
      in arrEnabled) arrs;

    envAttrs = builtins.listToAttrs (lib.concatMap (arr:
      let
        sub = cfg.${arr} or { };
        arrService = config.homelab.services.${arr} or { };
        upper = lib.toUpper arr;
        url = sub.url or (arrService.url or "http://${arr}.local");
      in lib.optionals (lib.elem arr enabledArrs) ([{
        name = "UN_${upper}_0_URL";
        value = url;
      }] ++ lib.optional ((sub.dataDir or "") != "") {
        name = "UN_${upper}_0_PATHS_0";
        value = sub.dataDir;
      })) enabledArrs);

    envFiles =
      map (arr: config.sops.templates."${arr}Unpackerr".path) enabledArrs;
  in {
    sops.secrets = builtins.listToAttrs (map (arr: {
      name = "${arr}ApiKey";
      value = { };
    }) enabledArrs);
    sops.templates = builtins.listToAttrs (map (arr: {
      name = "${arr}Unpackerr";
      value = {
        content = ''
          UN_${lib.toUpper arr}_0_API_KEY="${
            config.sops.placeholder."${arr}ApiKey"
          }"
        '';
      };
    }) enabledArrs);

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
        Environment = lib.mapAttrsToList (n: v: "${n}=${toString v}") envAttrs;
        EnvironmentFile = envFiles;
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:5656
      '';
    };
  });
}
