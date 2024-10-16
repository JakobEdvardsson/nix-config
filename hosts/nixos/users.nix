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
