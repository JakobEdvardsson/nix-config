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

    ./terminal

    (lib.custom.scanPaths ./.)
  ];

  inherit hostSpec;

  services.ssh-agent.enable = true;

  home = {
    username = lib.mkDefault config.hostSpec.username;
    homeDirectory = lib.mkDefault config.hostSpec.home;
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/scripts/talon_scripts"
    ];
    sessionVariables = {
      FLAKE = "$HOME/nix-config";
      SHELL = "fish";
      BROWSER = "brave";
      FILES = "nautilus";
      TERM = "kitty";
      TERMINAL = "kitty";
      VISUAL = "nvim";
      EDITOR = "nvim";
      MANPAGER = "batman"; # see ./cli/bat.nix
    };
    preferXdgDirectories = true; # whether to make programs use XDG directories whenever supported
  };
  #TODO:(xdg) maybe move this to its own xdg.nix?
  # xdg packages are pulled in below
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      /*
        desktop = "${config.home.homeDirectory}/.desktop";
        documents = "${config.home.homeDirectory}/doc";
        download = "${config.home.homeDirectory}/downloads";
        music = "${config.home.homeDirectory}/media/audio";
        pictures = "${config.home.homeDirectory}/media/images";
        videos = "${config.home.homeDirectory}/media/video";
      */
      # publicshare = "/var/empty"; #using this option with null or "/var/empty" barfs so it is set properly in extraConfig below
      # templates = "/var/empty"; #using this option with null or "/var/empty" barfs so it is set properly in extraConfig below

      /*
        extraConfig = {
          # publicshare and templates defined as null here instead of as options because
          XDG_PUBLICSHARE_DIR = "/var/empty";
          XDG_TEMPLATES_DIR = "/var/empty";
        };
      */
    };
  };

  home.packages = with pkgs; [
    # Packages that don't have custom configs go here
    direnv
    btop # resource monitor
    htop # resource monitor
    coreutils # basic gnu utils
    curl
    dust # disk usage
    fd # tree style ls
    findutils # find
    fzf # fuzzy search
    jq # JSON pretty printer and manipulator
    nix-tree # nix package tree viewer
    fastfetch # fancier system info than pfetch
    ncdu # TUI disk usage
    pciutils
    pfetch # system info
    pre-commit # git hooks
    p7zip # compression & encryption
    ripgrep # better grep
    steam-run # for running non-NixOS-packaged binaries on Nix
    usbutils
    tree # cli dir tree viewer
    unzip # zip extraction
    unrar # rar extraction
    xdg-utils # provide cli tools such as `xdg-mime` and `xdg-open`
    xdg-user-dirs
    wev # show wayland events. also handy for detecting keypress codes
    wget # downloader
    zip # zip compression
    killall # kill process
    nh # Yet another nix cli helper
  ];

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
