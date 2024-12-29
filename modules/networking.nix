{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.lab.networking;
in
{
  options.lab.networking = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable custom networking configuration for this host.
      '';
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "my-host";
      description = "The hostname for the system.";
    };

    firewallEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable or disable the firewall.";
    };

    allowedTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "List of allowed TCP ports for the firewall.";
    };

    allowedUDPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "List of allowed UDP ports for the firewall.";
    };
  };

config = lib.mkIf cfg.enable {
    # Networking settings
    networking.networkmanager.enable = true;
    networking.hostName = cfg.hostName;
    networking.timeServers = cfg.timeServers;

    # Enable the firewall
    networking.firewall.enable = cfg.firewallEnable;

    # Configure allowed TCP and UDP ports
    networking.firewall.allowedTCPPorts = cfg.allowedTCPPorts;
    networking.firewall.allowedUDPPorts = cfg.allowedUDPPorts;
  };
}
}
