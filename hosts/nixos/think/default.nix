# ############################################################
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
    # ========== Disk Layout ==========
    #
    inputs.disko.nixosModules.disko
    (lib.custom.relativeToRoot "hosts/common/disks/ext4.nix")
    {
      _module.args = {
        disk = "/dev/nvme0n1";
      };
    }

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

  customOption = {
    comin.enable = true;
    intel-quicksync.enable = true;
    deploy.enable = true;
    tailscale.enable = true;
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
