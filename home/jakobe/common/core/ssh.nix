{ config, lib, pkgs, ... }: {
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        ServerAliveInterval 30
        ServerAliveCountMax 3
    '';
  };
  home.packages = with pkgs; [ sshfs ];
}
