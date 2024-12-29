{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lab.audio;
in
{
  options.lab.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable audio support";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    hardware.pulseaudio.enable = false; # Disable PulseAudio if using PipeWire
  };
}
