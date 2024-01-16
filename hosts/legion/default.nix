# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # Nixos-hardware
    inputs.nixos-hardware.nixosModules.lenovo-legion-16achg6-hybrid
    # inputs.hardware.nixosModules.common-ssd
    ../../modules/system.nix
    ../../modules/i3.nix

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  # Specialised boot entry
  # No Nvidia GPU
  specialisation = {
    IGPU.configuration = {
      system.nixos.tags = ["IGPU"];

      # Probably not needed
      hardware.nvidia = {
        package = null;
        nvidiaSettings = false;
      };

      imports = [
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
        # auto cpufreq breaks with gpu
        ../../modules/power/auto-cpufreq.nix
      ];
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  services.power-profiles-daemon.enable = lib.mkDefault true;

  # Hostname.
  networking.hostName = "legion";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [config.boot.kernelPackages.lenovo-legion-module];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true;
  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    jakobe = {
      isNormalUser = true;
      description = "Jakob Edvardsson";
      extraGroups = ["networkmanager" "wheel"];
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sysstat
    lm_sensors # for `sensors` command
    # minimal screen capture tool, used by i3 blur lock to take a screenshot
    # print screen key is also bound to this tool in i3 config
    scrot
    neofetch
    xfce.thunar # xfce4's file manager
    powertop

    firefox
    lenovo-legion
  ];

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = false;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
