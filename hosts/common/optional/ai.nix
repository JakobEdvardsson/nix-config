{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.customOption.ai;
in
{

  options.customOption.ai = {
    enable = lib.mkEnableOption "Enable ai";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      config = {
        cudaSupport = false;
        allowUnfree = true;
      };

      # Set ctranslate2 cuda support
      overlays = [
        (final: prev: {
          ctranslate2 = prev.ctranslate2.override {
            withCUDA = true;
            withCuDNN = true;
          };
        })
      ];
    };

    environment.systemPackages = with pkgs; [
      python3Packages.pytorch-bin
      whisper-ctranslate2
    ];
  };
}
