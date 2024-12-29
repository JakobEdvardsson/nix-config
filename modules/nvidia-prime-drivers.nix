{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.nvidia.nvidia-prime;
in
{
  options.lab.nvidia.nvidia-prime = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nvidia Prime Hybrid GPU Offload";
    };

    # Bus IDs for Nvidia and Intel GPUs
    intelBusID = lib.mkOption {
      type = lib.types.str;
      default = "PCI:1:0:0";
      description = "PCI Bus ID of the Intel GPU.";
    };

    nvidiaBusID = lib.mkOption {
      type = lib.types.str;
      default = "PCI:1:0:0";
      description = "PCI Bus ID of the Nvidia GPU.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.nvidia = {
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        # Ensure the correct Bus ID values are used for your system
        intelBusId = cfg.intelBusID;
        nvidiaBusId = cfg.nvidiaBusID;
      };
    };
  };
}
