{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customOption.tailscale;
in
{

  options.customOption.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";
    advertisedRoute = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
      example = ''
        [
          "192.168.20.0/24"
          "192.168.50.0/24"
        ]
      '';
      description = ''
        Advertised Route
      '';
    };

  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      tailscaleAuthKey = { };
    };

    environment.systemPackages = [ pkgs.tailscale ];

    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
      extraUpFlags =
        lib.optionals (cfg.advertisedRoute != [ ]) [
          "--advertise-routes=${lib.concatStringsSep "," cfg.advertisedRoute}"
        ]
        ++ [ "--reset" ];
    };
  };
}
