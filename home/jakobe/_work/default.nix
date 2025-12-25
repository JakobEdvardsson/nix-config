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

  # customHome = {
  #   development.enable = true;
  # };

  inherit hostSpec;

  home = {
    username = lib.mkDefault config.hostSpec.username;
    homeDirectory = lib.mkDefault config.hostSpec.home;
    stateVersion = lib.mkDefault "23.05";
  };

  stylix = {
    enable = true;
    autoEnable = false;
    targets = {
      kitty.enable = true;
      neovim.enable = true;
      tmux.enable = true;
      lazygit.enable = true;
      fish.enable = true;
    };

    image = pkgs.fetchurl {
      url = "https://wallpaperbat.com/img/850807-legion-gaming-community.jpg";
      sha256 = "pLYV4/ypmA0IRzFofxRBllAkgMEwsQWBsIBSagUmNx0=";
    };
    imageScalingMode = "fit";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
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
