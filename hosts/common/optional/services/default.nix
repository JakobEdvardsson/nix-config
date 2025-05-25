# TODO make it so that all files in optional are options
{ lib, ... }:
{
  #imports = (lib.custom.scanPaths ./.);
  imports = [ ./docker.nix ];
}
