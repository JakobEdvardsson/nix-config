{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.ssh = {
    enable = true;
  };
  home.packages = with pkgs; [ sshfs ];
}
