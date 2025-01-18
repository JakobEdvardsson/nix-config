{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      # Device imaging
      rpi-imager

      # Productivity
      drawio
      grimblast
      libreoffice

      # Media production
      obs-studio
      ;
  };
}
