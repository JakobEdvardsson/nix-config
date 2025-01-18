{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      trash-cli # trash managment
      eza # ls replacement
      ;
  };

  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      ls = "eza $argv";
      ll = "eza -laa $argv";
      tree = "eza -T $argv";
      tp = "trash-put $argv";
      rm = "echo 'Stop using rm, use tp (or trash-put) instead'";
    };
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
