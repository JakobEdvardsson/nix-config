{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains.idea-ultimate
    vscode
    github-desktop

    jdk
  ];
}
