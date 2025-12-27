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

      settings = {
        user = {
          name = config.hostSpec.handle;
          email = config.hostSpec.email;
        };

        init.defaultBranch = "main";
      };
    };
    gh = {
      enable = true;
      settings.editor = "nvim";
      settings.git_protocol = "ssh";
    };
  };
  home.packages = with pkgs; [ lazygit ];
}
