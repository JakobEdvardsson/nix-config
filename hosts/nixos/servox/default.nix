#############################################################
#
#  Servox - Server VM
#  Ryzen 5 5700X, Amd Radeon 6950xt
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

    #
    # ========== Disk Layout ==========
    #
    #TODO: implement/remove

    /*
      inputs.disko.nixosModules.disko
      (lib.custom.relativeToRoot "hosts/common/disk/hybrid.nix")
      {
        _module.args = {
          disk = "/dev/disk/by-uuid/071edf10-af7a-4c50-8619-e54c2888a852";
        };
      }
    */

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
      # "hosts/common/optional/services/greetd.nix" # display manager
      "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      # "hosts/common/optional/services/printing.nix" # CUPS
      "hosts/common/optional/audio.nix" # pipewire and cli controls
      # "hosts/common/optional/bluetooth.nix" # bluetooth and blueman
      "hosts/common/optional/libvirt.nix" # vm tools
      # "hosts/common/optional/gaming.nix" # steam, gamescope, gamemode, and related hardware
      # "hosts/common/optional/msmtp.nix" # for sending email notifications
      # "hosts/common/optional/obsidian.nix" # wiki
      "hosts/common/optional/plymouth.nix" # fancy boot screen
      # "hosts/common/optional/thunar.nix" # file manager
      "hosts/common/optional/vlc.nix" # media player
      "hosts/common/optional/zsa-keeb.nix" # Moonlander keeb flashing stuff

    ])
    #
    # ========== Ghost Specific ==========
    #
    # ./samba.nix

  ];

  #
  # ========== Host Specification ==========
  #
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1031"; # used to be necessary, but doesn't seem to anymore
    };
    rocmOverrideGfx = "10.3.1";
  };

  hostSpec = {
    hostName = "servox";
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
    kernelModules = [ "amdgpu" ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.qemuGuest.enable = true;

  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  # https://github.com/NixOS/nixpkgs/issues/369376
  # https://github.com/kachick/dotfiles/issues/959
  # https://github.com/NixOS/nixpkgs/issues/223690

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
