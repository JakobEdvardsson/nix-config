{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.tailscale;

  routeSubnets = cfg.routeSubnets;

  routingFeatures =
    if cfg.acceptRoutes && cfg.advertiseRoutes then "both"
    else if cfg.acceptRoutes then "client"
    else if cfg.advertiseRoutes then "server"
    else "none";

  extraUpFlags =
    lib.optionals cfg.acceptRoutes [ "--accept-routes" ]
    ++ lib.optionals cfg.advertiseRoutes [
      "--advertise-routes=${lib.concatStringsSep "," routeSubnets}"
    ];

  # Build an ExecStart list of commands for each subnet
  ipRules = lib.concatStringsSep " && " (
    builtins.map (
      subnet: "${pkgs.iproute2}/bin/ip rule add to ${subnet} priority 2500 lookup main || true"
    ) routeSubnets
  );
in
{
  options.customOption.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";

    advertiseRoutes = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable advertising local subnets via Tailscale.";
    };

    acceptRoutes = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable accepting routes from other Tailscale nodes.";
    };

    routeSubnets = lib.mkOption {
      default = [ "10.0.0.0/24" ];
      type = lib.types.listOf lib.types.str;
      example = ''
        [
          "192.168.20.0/24"
          "192.168.50.0/24"
        ]
      '';
      description = ''
        Route subnet for advertised route and/or accept-routes
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (!cfg.advertiseRoutes) || routeSubnets != [];
        message = "customOption.tailscale.routeSubnets must be set when advertiseRoutes is enabled.";
      }
    ];

    environment.systemPackages = [ pkgs.tailscale ];

    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.tailscale = {
      enable = true;
      openFirewall = true;
    } // lib.optionalAttrs (cfg.acceptRoutes || cfg.advertiseRoutes) {
      useRoutingFeatures = routingFeatures;
      extraUpFlags = extraUpFlags;
    };

    # Add ip rules for advertised/accepted subnets via systemd
    systemd.services.add-ip-routes = lib.mkIf
      (routeSubnets != [] && (cfg.acceptRoutes || cfg.advertiseRoutes))
      {
        description = "Add custom IP rules for routed subnets (tailscale)";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c ${lib.escapeShellArg ipRules}";
          RemainAfterExit = true;
        };
      };
  };
}
