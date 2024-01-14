{
  lib,
  pkgs,
  catppuccin-bat,
  ...
}: {
  home.packages = with pkgs; [
    spotify

    # archives
    zip
    unzip
    p7zip

    # utils
    ripgrep
    htop

    # misc
    libnotify
    wineWowPackages.wayland
    xdg-utils
    graphviz
  ];

  programs = {
    btop.enable = true; # replacement of htop/nmon
    eza.enable = true; # A modern replacement for ‘ls’
    jq.enable = true; # A lightweight and flexible command-line JSON processor
    ssh.enable = true;
    aria2.enable = true;

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };
  };

  services = {
    # auto mount usb drives
    udiskie.enable = true;
  };
}
