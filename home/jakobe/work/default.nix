{
  config,
  lib,
  pkgs,
  hostSpec,
  ...
}:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/nixos/host-spec.nix"
      "modules/home-manager"
    ])
    ../common/optional
    ../common/core/terminal/fish.nix
    ../common/core/terminal/tmux.nix
    ../common/core/terminal/zoxide.nix
    ../common/core/neovim
    ../common/core/fonts.nix
  ];

  customHome = {
    development.enable = true;
  };

  inherit hostSpec;

  home = {
    username = lib.mkDefault config.hostSpec.username;
    homeDirectory = lib.mkDefault config.hostSpec.home;
    stateVersion = lib.mkDefault "23.05";
  };

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

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
