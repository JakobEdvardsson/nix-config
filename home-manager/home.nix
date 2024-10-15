{ pkgs, ...
}:{ 
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


 # home.file.".config/ags" = {
 #   source = ./config/ags;
 #   # copy the ags configuration directory recursively
 #   recursive = true;
 # };
  
  home.stateVersion = "24.05";
}

