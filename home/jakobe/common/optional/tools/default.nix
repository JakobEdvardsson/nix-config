{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = with pkgs; [
    # Device imaging
    rpi-imager

    # Productivity
    drawio
    grimblast
    caprine

    # Media production
    obs-studio
  ];
}
