{ inputs, pkgs, lib, ... }: {
  imports = [
    #./thunar.nix # file manager
    ./nautilus.nix # file manager
    ./audio.nix # pipewire and cli controls
    ./bluetooth.nix # bluetooth and blueman
    #TODO: add a display manager
  ];

  programs.hyprland = { enable = true; };

  environment.systemPackages = [ ];
}
