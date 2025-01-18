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
      tp = "trash put $argv";
      rm = "echo 'Stop using rm, use trash put (or tp) instead'";
    };
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
