{ lib, ... }: {
  imports = [
    ./binds.nix
    ./decoration.nix
    ./general.nix
    ./gestures.nix
    ./startup-script.nix
    ./emoji.nix
    ./window-rules.nix
    ./animations.nix
  ];
}
