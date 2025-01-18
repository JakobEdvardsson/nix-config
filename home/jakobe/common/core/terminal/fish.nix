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
    shellAliases = {
      mkdir = "mkdir -pv"; # * Create missing directories in path when calling `mkdir`
      rmm = "rm -rvI"; # * `rmm` command to remove directories, but ask nicely
      cpp = "cp -R"; # * `cpp` command to copy directories, but ask nicely
      cp = "cp -i"; # * `cp` to ask when overwriting files
      mv = "mv -i"; # * `mv` to ask when overwriting files

      #  * Human readable sizes for `df`, `du`, `free` (i.e. Mb, Gb etc)
      df = "df -h";
      du = "du -ch";
      free = "free -m";
    };
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

      copy = ''
        function copy --description "Copy pipe or argument"
          if [ "$argv" = "" ]
            fish_clipboard_copy
          else
            printf "$argv" | fish_clipboard_copy
          end
        end
      '';

    };
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
