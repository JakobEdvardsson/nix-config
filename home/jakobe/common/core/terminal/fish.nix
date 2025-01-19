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
      ripgrep
      ;
  };

  programs.fish = {
    enable = true;
    shellAliases = rec {
      # Eza ls replacement
      ls = "${pkgs.eza}/bin/eza --group-directories-first";
      l = "${ls} -lbF --git --icons";
      ll = "${l} -G";
      la = "${ls} -lbhHigmuSa@ --time-style=long-iso --git --color-scale --icons";
      lt = "${ls} --tree --level=2 --icons";

      mkdir = "mkdir -pv"; # * Create missing directories in path when calling `mkdir`
      rmm = "rm -rvI"; # * `rmm` command to remove directories, but ask nicely
      cpp = "cp -R"; # * `cpp` command to copy directories, but ask nicely
      cp = "cp -i"; # * `cp` to ask when overwriting files
      mv = "mv -i"; # * `mv` to ask when overwriting files

      #  * Human readable sizes for `df`, `du`, `free` (i.e. Mb, Gb etc)
      df = "df -h";
      du = "du -ch";
      free = "free -m";

      #-------------Bat related------------
      cat = "${pkgs.bat}/bin/bat --paging=never";
      diff = "${pkgs.bat-extras.batdiff}/bin/batdiff";
      rg = "${pkgs.bat-extras.batgrep}/bin/batgrep";
      man = "${pkgs.bat-extras.batman}/bin/batman";

      # git;
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ga = "git add";
      gp = "git push";
      gc = "git commit";
      gco = "git checkout";
      gs = "git status";
      gca = "git commit --amend";
      gd = "git diff";
      gdc = "git diff --cached";
      gir = "git rebase -i";
      gpr = "gh pr create";
      gdpr = "gh pr create --draft";

      # Less used ones:
      lsblk = "lsblk -o name,mountpoint,label,size,type,uuid";
      weather = "${pkgs.curl}/bin/curl -4 http://wttr.in/Malmö";

    };
    functions = {
      fish_greeting = "";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      tree = "eza -T $argv";

      #trash
      tp = "${pkgs.trash-cli}/bin/trash-put $argv";
      tl = "${pkgs.trash-cli}/bin/trash-list $argv";
      tempty = "${pkgs.trash-cli}/bin/trash-empty $argv";
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
