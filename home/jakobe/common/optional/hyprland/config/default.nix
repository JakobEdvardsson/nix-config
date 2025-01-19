{ lib, ... }:
{
  imports = [
    ./binds.nix
    ./decoration.nix
    ./general.nix
    ./gestures.nix
    ./startupScript.nix
  ];
}
