{
  pkgs,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    userName = "Jakob Edvardsson";
    userEmail = "Jakob.Edvardsson@outlook.com";
  };
}