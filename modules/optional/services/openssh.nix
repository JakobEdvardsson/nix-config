{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customOption.openssh;
  # sshPort = config.hostSpec.networking.ports.tcp.ssh;
  sshPort = 22;
in
{
  options.customOption.openssh = {
    enable = lib.mkEnableOption "Enable openssh";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ sshPort ];

      settings = {
        # Harden
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        # Automatically remove stale sockets
        # StreamLocalBindUnlink = "yes";
        # Allow forwarding ports to everywhere
        # GatewayPorts = "clientspecified";
      };

      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      openFirewall = true;
    };
  };
}
