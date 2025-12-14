{ pkgs, lib, config, ... }:
let cfg = config.customOption.intel-quicksync;
in {
  options.customOption.intel-quicksync = {
    enable = lib.mkEnableOption "Enable intel-quicksync";
  };

  config = lib.mkIf cfg.enable {
    # intel hardware acceleration
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
          libva-vdpau-driver
          intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
          vpl-gpu-rt # QSV on 11th gen or newer
        ];
      };
    };
  };
}
