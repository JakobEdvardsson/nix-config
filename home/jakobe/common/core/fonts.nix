{ pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.noto-fonts
    pkgs.nerd-fonts.jetbrains-mono # loads the complete collection. look into overide for FiraMono or potentially mononoki
    pkgs.meslo-lgs-nf
    # pkgs.jetbrains-mono
  ];
}
