{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.nvidia;
in
{
  options.lab.nvidia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nvidia Drivers";
    };

    # Option for configuring the Nvidia video drivers
    nvidiaSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Nvidia settings menu via 'nvidia-settings'.";
    };

    # Power management options
    powerManagementEnable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable Nvidia power management.";
    };

    powerManagementFinegrained = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable fine-grained power management (turn off GPU when not in use).";
    };

    openKernelModule = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use the Nvidia open-source kernel module (limited support).";
    };

    package = lib.mkOption {
      type = lib.types.str;
      default = "nvidiaPackages.stable";
      description = "Package to use for Nvidia drivers.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure Nvidia video driver
    services.xserver.videoDrivers = [ "nvidia" ];

    # Configure Nvidia hardware settings
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = cfg.powerManagementEnable;
      powerManagement.finegrained = cfg.powerManagementFinegrained;
      open = cfg.openKernelModule;
      nvidiaSettings = cfg.nvidiaSettings;
      package = config.boot.kernelPackages.${cfg.package};
    };
  };
}
