{pkgs, ...}: {
  home.packages = with pkgs; [
    vim
    lazygit
    lunarvim
  ];
  #programs.neovim = {
  #  enable = true;
  #};
}
