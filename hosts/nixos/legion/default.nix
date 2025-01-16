#############################################################
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
    #TODO: implement/remove
    inputs.stylix.nixosModules.stylix

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
      # "hosts/common/optional/services/openssh.nix" # allow remote SSH access
      # "hosts/common/optional/services/printing.nix" # CUPS
      "hosts/common/optional/audio.nix" # pipewire and cli controls
      "hosts/common/optional/bluetooth.nix" # bluetooth and blueman
      "hosts/common/optional/libvirt.nix" # vm tools
      # "hosts/common/optional/gaming.nix" # steam, gamescope, gamemode, and related hardware
      # "hosts/common/optional/msmtp.nix" # for sending email notifications
      "hosts/common/optional/nvtop.nix" # GPU monitor (not available in home-manager)
      # "hosts/common/optional/obsidian.nix" # wiki
      "hosts/common/optional/plymouth.nix" # fancy boot screen
      "hosts/common/optional/thunar.nix" # file manager
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

  hostSpec = {
    # TODO: look this up!
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

  #TODO:(stylix) move this stuff to separate file but define theme itself per host
  # host-wide styling
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    }; # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    #      cursor = {
    #        package = pkgs.foo;
    #        name = "";
    #      };
    #     fonts = {
    #monospace = {
    #    package = pkgs.foo;
    #    name = "";
    #};
    #sanSerif = {
    #    package = pkgs.foo;
    #    name = "";
    #};
    #serif = {
    #    package = pkgs.foo;
    #    name = "";
    #};
    #    sizes = {
    #        applications = 12;
    #        terminal = 12;
    #        desktop = 12;
    #        popups = 10;
    #    };
    #};
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 0.8;
    };
    polarity = "dark";
    # program specific exclusions
    #targets.foo.enable = false;
  };
  #hyprland border override example
  #  wayland.windowManager.hyprland.settings.general."col.active_border" = lib.mkForce "rgb(${config.stylix.base16Scheme.base0E});

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
