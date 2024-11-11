{ pkgs, username, ... }:
{

  users = {
    users."jakobe" = {
      homeMode = "755";
      isNormalUser = true;
      description = "Jakob Edvardsson";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "video"
        "input"
        "audio"
        "dialout"
        "plugdev"
        "docker"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1aUDp1c38txQmImBCSU9N3zSRSNNWdeZvUBSx6QtLr jakobe"
      ];
      # define user packages here
      packages =
        with pkgs;
        [
        ];
    };

    defaultUserShell = pkgs.fish;
  };

  environment.shells = with pkgs; [ zsh ];
  environment.systemPackages = with pkgs; [
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fzf
    fishPlugins.grc
    grc
  ];

  programs.fish.enable = true;
}
