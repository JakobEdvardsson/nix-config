{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.tailscale;

  # Build an ExecStart list of commands for each subnet
  ipRules = lib.concatStringsSep " && " (
    builtins.map (
      subnet: "${pkgs.iproute2}/bin/ip rule add to ${subnet} priority 2500 lookup main || true"
    ) cfg.routeSubnets
  );
in
{
  options.customOption.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";

    # advertise-routes = lib.mkOption {
    #   default = false;
    #   type = lib.types.bool;
    #   description = "Enable advertising local subnets via Tailscale";
    # };
    #
    # accept-routes = lib.mkOption {
    #   default = false;
    #   type = lib.types.bool;
    #   description = "Enable accepting routes from other Tailscale nodes";
    # };

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
    # sops.secrets = {
    #   tailscaleAuthKey = { };
    # };

    environment.systemPackages = [ pkgs.tailscale ];

    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.tailscale = {
      enable = true;
      # authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
      useRoutingFeatures = "both";
      openFirewall = true;
      # extraUpFlags =
      #   lib.optionals cfg.accept-routes [ "--accept-routes" ] ++
      #   lib.optionals cfg.advertise-routes [
      #     "--advertise-routes=${lib.concatStringsSep "," cfg.routeSubnets}"
      #   ] ++
      #   [ "--reset" ];
    };

    # Add ip rules for advertised/accepted subnets via systemd
    systemd.services.add-ip-routes = {
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
