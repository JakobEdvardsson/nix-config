{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  # host-wide styling
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://wallpaperbat.com/img/850807-legion-gaming-community.jpg";
      sha256 = "pLYV4/ypmA0IRzFofxRBllAkgMEwsQWBsIBSagUmNx0=";
    };
    imageScalingMode = "fit";
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        # package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };

      /*
        monospace = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans Mono";
        };
      */

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        terminal = 12;
        desktop = 12;
        popups = 10;
      };
    };
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 0.9;
    };
    polarity = "dark";
  };
}
