{ 
  imports = [ ];

  home = {
    username = "jakobe";
    homeDirectory = "/home/jakobe";
  };
 # home.file.".config/ags" = {
 #   source = ./config/ags;
 #   # copy the ags configuration directory recursively
 #   recursive = true;
 # };
  
  home.stateVersion = "24.05";
}

