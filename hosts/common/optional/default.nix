# TODO make it so that all files in optional are options
{ lib, ... }:
{
  #imports = (lib.custom.scanPaths ./.);
  imports = [
    ./intel-quicksync.nix
    ./nix-ld.nix
    ./droidcam.nix
    ./ai.nix
    ./services/docker.nix
  ];
}
