{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.amdgpu;
in
{
  options.lab.amdgpu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable graphics support";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

    hardware.graphics = {
      enable = lib.mkDefault true;
    };

    hardware.amdgpu.initrd.enable = lib.mkDefault true;
  };
}
