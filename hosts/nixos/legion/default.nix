# ############################################################
#
#  Legion - Main Laptop
#  NixOS running on Lenovo Legion 7 16achg6
#  Ryzen 5 5800H, Nvidia RTX 3080 mobile, 16GB RAM
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
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc
    inputs.hardware.nixosModules.common-pc-laptop # TODO: Sets up powermanager, remove if using tlp

    #
    # ========== Disk Layout ==========
    #
    #TODO: implement/remove

    # inputs.disko.nixosModules.disko
    # (lib.custom.relativeToRoot "hosts/common/disk/hybrid.nix")
    # {
    #   _module.args = {
    #     disk = "/dev/disk/by-uuid/071edf10-af7a-4c50-8619-e54c2888a852";
    #   };
    # }
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

      "hosts/common/optional/hyprland.nix" # window manager
      #"hosts/common/optional/nvidia-prime.nix" # nvidia-prime
      # "hosts/common/optional/services/greetd.nix" # display manager
      # "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      # "hosts/common/optional/services/printing.nix" # CUPS
      "hosts/common/optional/audio.nix" # pipewire and cli controls
      "hosts/common/optional/bluetooth.nix" # bluetooth and blueman
      "hosts/common/optional/libvirt.nix" # vm tools
      # "hosts/common/optional/gaming.nix" # steam, gamescope, gamemode, and related hardware
      # "hosts/common/optional/msmtp.nix" # for sending email notifications
      # "hosts/common/optional/obsidian.nix" # wiki
      "hosts/common/optional/plymouth.nix" # fancy boot screen
      # "hosts/common/optional/thunar.nix" # file manager
      "hosts/common/optional/mpv.nix" # media player
      "hosts/common/optional/zsa-keeb.nix" # Moonlander keeb flashing stuff
    ])
  ];

  customOption = {
    nvidia-prime.enable = true;
    tailscale.enable = true;
    nix-ld.enable = true;
    docker.enable = true;
    droidcam.enable = true;
    ai.enable = true;
  };

  # Hibernate
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  boot.kernelParams = [ "resume_offset=28895232" ];
  boot.resumeDevice = "/dev/disk/by-uuid/0661ad46-7c3d-48e2-b964-e874f3b6c37a";
  powerManagement.enable = true;

  specialisation = {
    amd.configuration = {
      system.nixos.tags = [ "amd" ];
      customOption.nvidia-prime.enable = lib.mkForce false;
      customOption.nvidia.enable = lib.mkForce false;
      imports = [ inputs.hardware.nixosModules.common-gpu-nvidia-disable ];
    };
  };

  hostSpec = {
    hostName = "legion";
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

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
