#############################################################
#
#  Think - ThinkCentre M70q Gen 3 Tiny
#  Intel Core i5-12400T
#
###############################################################

{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = lib.flatten [
    #
    # ========== Hardware ==========
    #
    ./hardware.nix
    ./homelab.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc

    #
    # ========== Misc Inputs ==========
    #
    (map lib.custom.relativeToRoot [
      #
      # ========== Required Configs ==========
      #
      "hosts/common/core"
      #
      # ========== Optional Configs ==========
      #
      #TODO: implement/remove

      "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      "hosts/common/optional/plymouth.nix" # fancy boot screen

    ])
  ];

  #
  # ========== Host Specification ==========
  #

  customOption.tailscale = {
    enable = true;
    advertisedRoute = [
      "192.168.50.0/24"
    ];
  };

  fileSystems.${config.homelab.mounts.slow} = {
    device = "/dev/disk/by-uuid/1e3795b5-c1e2-4c6d-9663-1600b4efa33e";
    options = [
      "defaults"
      "noatime" # Avoids writing access times, improves performance
      "errors=remount-ro" # Remount as read-only on failure
      "x-mount.mkdir" # Creates the mount directory if missing
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
    fsType = "ext4";
  };

  fileSystems.${config.homelab.mounts.fast} = {
    device = "/dev/disk/by-uuid/e19d961a-c436-452d-8735-2be06a7e296d";
    options = [
      "defaults"
      "noatime" # Avoids writing access times, improves performance
      "errors=remount-ro" # Remount as read-only on failure
      "x-mount.mkdir" # Creates the mount directory if missing
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
    fsType = "ext4";
  };

  hostSpec = {
    hostName = "think";
  };

  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      # When using plymouth, initrd can expand by a lot each time, so limit how many we keep around
      configurationLimit = lib.mkDefault 10;
    };
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  boot.initrd = {
    systemd.enable = true;
  };

  boot.kernelPackages = pkgs.linuxPackages;

  system.stateVersion = "24.05";
}
