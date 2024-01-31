{pkgs, ...}: {
  home.packages = with pkgs; [
    vim
    lazygit
    lunarvim
    neovim
  ];
  #programs.neovim = {
  #  enable = true;
  #};
  
  home.file.".config/nvim/init.ua".source = ./init.lua;
}
