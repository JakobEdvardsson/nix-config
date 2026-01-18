{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.customOption.tailscale;

  flags = builtins.filter (s: s != "") [
    (if cfg.enableSshAgent then "--ssh" else "")
    (if cfg.advertiseTags == null then "" else "--advertise-tags=${cfg.advertiseTags}")
    (if cfg.exitNode then "--advertise-exit-node" else "")
    (
      if cfg.acceptDns == null then
        ""
      else if cfg.acceptDns then
        "--accept-dns"
      else
        "--accept-dns=false"
    )
    (if cfg.advertiseRoutes == null then "" else "--advertise-routes=${cfg.advertiseRoutes}")
    (if cfg.acceptRoutes then "--accept-routes" else "")
    (if cfg.acceptRisk == null then "" else "--accept-risk=${cfg.acceptRisk}")
  ];
  advertisedRouteList =
    if cfg.advertiseRoutes == null then
      [ ]
    else
      lib.filter (s: s != "") (
        map lib.strings.trim (lib.strings.splitString "," cfg.advertiseRoutes)
      );
  ipRulesText = lib.concatStringsSep " && " (map (
    subnet:
    "${pkgs.iproute2}/bin/ip rule add to ${lib.escapeShellArg subnet} priority 2500 lookup main || true"
  ) advertisedRouteList);

  routingFeatures =
    if (cfg.exitNode || cfg.advertiseRoutes != null) && cfg.acceptRoutes then
      "both"
    else if (cfg.exitNode || cfg.advertiseRoutes != null) then
      "server"
    else if cfg.acceptRoutes then
      "client"
    else
      "none";
in
{
  options.customOption.tailscale = with lib; {
    enable = mkEnableOption "Enable tailscale";

    enableSshAgent = mkOption {
      description = "Allow Tailscale to run an SSH server.";
      type = types.bool;
      default = false;
    };

    exitNode = mkOption {
      description = "Allow current machine to be a Tailscale exit node.";
      type = types.bool;
      default = false;
    };

    advertiseRoutes = mkOption {
      description = "Advertise routes to the Tailscale network (subnet routing).";
      type = types.nullOr types.str;
      example = "192.168.1.0/24";
      default = null;
    };

    acceptDns = mkOption {
      description = "Accept DNS config from the Tailscale network (null to omit flag).";
      type = types.nullOr types.bool;
      default = null;
    };

    acceptRoutes = mkOption {
      description = "Accept routes from the Tailscale network.";
      type = types.bool;
      default = false;
    };

    advertiseTags = mkOption {
      description = "Advertise tags to the Tailscale network.";
      type = types.nullOr types.str;
      example = "tag:nixos";
      default = null;
    };

    acceptRisk = mkOption {
      description = "Accept risk when connecting to Tailscale.";
      type = types.nullOr types.str;
      example = "lose-ssh";
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ config.services.tailscale.package ];

    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.tailscale = {
      enable = true;
      openFirewall = true;
      extraUpFlags = flags;
      extraSetFlags = flags;
    }
    // lib.optionalAttrs (cfg.exitNode || cfg.advertiseRoutes != null || cfg.acceptRoutes) {
      useRoutingFeatures = routingFeatures;
    };

    systemd.services.tailscale-ip-rules = lib.mkIf (advertisedRouteList != [ ]) {
      description = "Add IP rules for advertised routes (tailscale)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c ${lib.escapeShellArg ipRulesText}";
        RemainAfterExit = true;
      };
    };
  };
}
