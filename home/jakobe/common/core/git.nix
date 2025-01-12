#TODO: add better rules for forcing ssh as per fb
{
  pkgs,
  lib,
  config,
  ...
}:
let
  handle = config.hostSpec.handle;
  publicGitEmail = config.hostSpec.email.gitHub;
in
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = handle;
    userEmail = publicGitEmail;
  };
}
