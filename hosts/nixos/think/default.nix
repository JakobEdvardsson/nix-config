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
  fileSystems.${config.homelab.mounts.slow} = {
    device = "/dev/disk/by-uuid/1e3795b5-c1e2-4c6d-9663-1600b4efa33e";
    options = [
      "defaults"
      "noatime" # Avoids writing access times, improves performance
      "errors=remount-ro" # Remount as read-only on failure
      "uid=994" # Set owner to UID 994
      "gid=993" # Set group to GID 993
      "umask=002" # Ensure group has write permission
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
