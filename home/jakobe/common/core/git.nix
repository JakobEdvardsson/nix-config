#TODO: add better rules for forcing ssh as per fb
{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs = {
    git = {
      enable = true;
    };
    gh = {
      enable = true;
      settings.editor = "nvim";
      settings.git_protocol = "ssh";
    };
  };
  home.packages = with pkgs; [
    github-desktop
  ];
}
