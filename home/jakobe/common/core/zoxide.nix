{
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishInegration = true;
    options = [
      "--cmd cd" # replace cd with z and zi (via cdi)
    ];
  };
}
