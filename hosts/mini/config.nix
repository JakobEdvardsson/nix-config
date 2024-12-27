# Main default config

{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./users.nix

    ./packages.nix
    ../../modules/networking.nix
    ../../modules/locale.nix

    ../../modules/nixos-hardware/cpu/intel
  ];

  # BOOT related stuff
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # Kernel

    kernelParams = [
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device" # this is to mask that stupid 1.5 mins systemd bug
      "nowatchdog"
    ];

    # v4l2loopback This is for OBS Virtual Cam Support
    kernelModules = [
      "v4l2loopback"
      "acpi_call"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
      v4l2loopback
    ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules =
        [
        ];
    };

    # Bootloader SystemD
    loader.systemd-boot.enable = true;

    loader.efi = {
      canTouchEfiVariables = true;
    };

    loader.timeout = 1;

    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };

  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8080
  ];
  networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  #services.power-profiles-daemon.enable = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # FONTS
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    noto-fonts-cjk-sans
    jetbrains-mono
    font-awesome
    terminus_font
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  services = {
    smartd = {
      enable = false;
      autodetect = true;
    };

    udev.enable = true;
    envfs.enable = true;
    dbus.enable = true;

    fstrim = {
      enable = true;
      interval = "weekly";
    };

    openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      #settings.PermitRootLogin = "yes";
    };

    qemuGuest.enable = true;
  };
  # zram
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 30;
    swapDevices = 1;
    algorithm = "zstd";
  };

  # Cachix, Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Virtualization / Containers
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    enableOnBoot = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  documentation.man.generateCaches = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
