{ inputs, pkgs, ... }:
{

  imports = [
    "hosts/common/optional/thunar.nix" # file manager
    "hosts/common/optional/audio.nix" # pipewire and cli controls
    "hosts/common/optional/bluetooth.nix" # bluetooth and blueman
    #TODO: add a display manager
  ];

  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages =
    [
    ];
}
