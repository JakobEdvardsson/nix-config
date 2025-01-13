#TODO: add better rules for forcing ssh as per fb
{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.git = {
    enable = true;
  };
}
