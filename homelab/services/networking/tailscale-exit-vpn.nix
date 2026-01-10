{
  config,
  lib,
  pkgs,
  ...
}:
let
  service = "tailscale-exit-vpn";
  homelab = config.homelab;
  cfg = homelab.services.${service};
  optionsFn = import ../../options.nix;
  ns = homelab.services.wireguard-netns.namespace;
  vethHost = "ts-vpn0";
  vethNamespace = "ts-vpn1";
  vethHostAddress = "10.254.0.1/30";
  vethNamespaceAddress = "10.254.0.2/30";
  vethHostIp = lib.head (lib.strings.splitString "/" vethHostAddress);
  enableLanBridge = cfg.lanInterface != null && cfg.lanCidr != null;
  baseFlags =
    [ "--advertise-exit-node" ]
    ++ (lib.optional (cfg.lanCidr != null) "--advertise-routes=${cfg.lanCidr}");
  upFlags = baseFlags ++ cfg.extraUpFlags;
  setFlags = baseFlags ++ cfg.extraSetFlags;
  upFlagsText = lib.concatStringsSep " " (map lib.escapeShellArg upFlags);
  setFlagsText = lib.concatStringsSep " " (map lib.escapeShellArg setFlags);
  runtimeDir = service;
  stateDir = service;
  socketPath = "/run/${runtimeDir}/tailscaled.sock";
  statePath = "/var/lib/${stateDir}/tailscaled.state";
  resolvConfPath = "/var/lib/${stateDir}/resolv.conf";
  resolvConfSource = pkgs.writeText "tailscale-exit-vpn-resolv.conf" ''
    nameserver ${homelab.services.wireguard-netns.dnsIP}
  '';
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
        description = "Tailscale exit node routed through VPN";
      };
    })
    // {
      lanInterface = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Host LAN interface used for homelab access (for NAT).";
      };
      lanCidr = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Homelab LAN CIDR to route via the host and advertise to Tailscale.";
      };
      extraUpFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra flags passed to `tailscale up` for the exit VPN instance.";
      };
      extraSetFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra flags passed to `tailscale set` for the exit VPN instance.";
      };
    };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = homelab.services.wireguard-netns.enable;
          message = "homelab.services.${service} requires homelab.services.wireguard-netns.enable = true.";
        }
      ];

      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      environment.systemPackages = [ pkgs.tailscale ];

      systemd.services."${service}-sysctl" = {
        description = "Enable routing inside ${ns} for Tailscale";
        bindsTo = [ "netns@${ns}.service" ];
        after = [ "netns@${ns}.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart =
            pkgs.writers.writeBash "tailscale-exit-vpn-sysctl" ''
              set -euo pipefail
              ${pkgs.iproute2}/bin/ip netns exec ${ns} ${pkgs.procps}/bin/sysctl -w net.ipv4.ip_forward=1
              ${pkgs.iproute2}/bin/ip netns exec ${ns} ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.forwarding=1
            '';
        };
      };

      systemd.services."${service}-resolvconf" = {
        description = "Prepare resolv.conf for ${service}";
        wantedBy = [ "multi-user.target" ];
        before = [ "${service}.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            pkgs.writers.writeBash "tailscale-exit-vpn-resolvconf" ''
              set -euo pipefail
              ${pkgs.coreutils}/bin/install -Dm 0644 ${resolvConfSource} ${resolvConfPath}
            '';
        };
      };

      systemd.services."${service}" = {
        description = "Tailscale in VPN netns (${ns})";
        bindsTo = [ "netns@${ns}.service" ];
        requires =
          [
            "network-online.target"
            "${ns}.service"
            "${service}-sysctl.service"
            "${service}-resolvconf.service"
          ]
          ++ lib.optional enableLanBridge "${service}-veth.service";
        after =
          [
            "netns@${ns}.service"
            "${ns}.service"
            "${service}-sysctl.service"
            "${service}-resolvconf.service"
          ]
          ++ lib.optional enableLanBridge "${service}-veth.service";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "notify";
          Restart = "on-failure";
          RuntimeDirectory = runtimeDir;
          StateDirectory = stateDir;
          BindPaths = [
            "${resolvConfPath}:/etc/resolv.conf"
          ];
          NetworkNamespacePath = [ "/var/run/netns/${ns}" ];
          ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=${statePath} --socket=${socketPath}";
        };
      };

      systemd.services."${service}-up" = {
        description = "Configure Tailscale exit VPN instance";
        after = [ "${service}.service" ];
        requires = [ "${service}.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            pkgs.writers.writeBash "tailscale-exit-vpn-up" ''
              set -euo pipefail
              ${pkgs.tailscale}/bin/tailscale --socket=${socketPath} up ${upFlagsText}
              if [ -n "${setFlagsText}" ]; then
                ${pkgs.tailscale}/bin/tailscale --socket=${socketPath} set ${setFlagsText}
              fi
            '';
        };
      };
    }
    (lib.mkIf enableLanBridge {
      networking.nat = {
        enable = true;
        internalInterfaces = [ vethHost ];
        externalInterface = cfg.lanInterface;
      };
      networking.firewall.trustedInterfaces = [ vethHost ];

      systemd.services."${service}-veth" = {
        description = "Veth bridge from host to ${ns} for Tailscale LAN access";
        bindsTo = [ "netns@${ns}.service" ];
        after = [ "netns@${ns}.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart =
            pkgs.writers.writeBash "tailscale-exit-vpn-veth-up" ''
              set -euo pipefail
              ${pkgs.iproute2}/bin/ip link del ${vethHost} 2>/dev/null || true
              ${pkgs.iproute2}/bin/ip link add ${vethHost} type veth peer name ${vethNamespace}
              ${pkgs.iproute2}/bin/ip link set ${vethNamespace} netns ${ns}
              ${pkgs.iproute2}/bin/ip addr add ${vethHostAddress} dev ${vethHost}
              ${pkgs.iproute2}/bin/ip link set ${vethHost} up
              ${pkgs.iproute2}/bin/ip -n ${ns} addr add ${vethNamespaceAddress} dev ${vethNamespace}
              ${pkgs.iproute2}/bin/ip -n ${ns} link set ${vethNamespace} up
              ${pkgs.iproute2}/bin/ip -n ${ns} route replace ${cfg.lanCidr} via ${vethHostIp} dev ${vethNamespace}
            '';
          ExecStop =
            pkgs.writers.writeBash "tailscale-exit-vpn-veth-down" ''
              set -euo pipefail
              ${pkgs.iproute2}/bin/ip link del ${vethHost} 2>/dev/null || true
            '';
        };
      };
    })
  ]);
}
