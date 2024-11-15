{
  pkgs,
  ...
}:
{
  imports = [
    ./neovim.nix
  ];

  home = {
    username = "jakobe";
    homeDirectory = "/home/jakobe";
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.stateVersion = "24.05";
}
