# TODO: add better rules for forcing ssh as per fb
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
      userName = config.hostSpec.handle;
      userEmail = config.hostSpec.email;
      extraConfig.init.defaultBranch = "main";
    };
    gh = {
      enable = true;
      settings.editor = "nvim";
      settings.git_protocol = "ssh";
    };
  };
  home.packages = with pkgs; [
    github-desktop
    lazygit
  ];
}
