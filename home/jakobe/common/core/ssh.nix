{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = true;
  };
  home.packages = with pkgs; [ sshfs ];
}
