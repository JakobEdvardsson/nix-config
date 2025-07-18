{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  home.packages = with pkgs; [
    eza
    bat
    bat-extras.batgrep
    ripgrep
    bat-extras.batman

    trash-cli
  ];

  programs.fish = {
    enable = true;
    shellAliases = rec {
      # Eza ls replacement
      ls = "eza --group-directories-first -g";
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

      #trash
      tp = "trash-put";
      tl = "trash-list";
      tempty = "trash-empty";

      #-------------Bat related------------
      cat = "bat --paging=never";
      rg = "batgrep";
      man = "batman";

      # git;
      gl = "git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ga = "git add";
      push = "git push";
      pull = "git pull";
      gc = "git commit";
      gco = "git checkout";
      gs = "git status";
      gca = "git commit --amend";
      gd = "git diff";
      gdc = "git diff --cached";
      gir = "git rebase -i";
      gpr = "gh pr create";
      gdpr = "gh pr create --draft";

      # Always attemp to attach to session requires: newSession = true;
      mux = "tmux a";
      k = "kubectl";

      # kitty
      s = "kitten ssh";
      icat = "kitten icat";

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

      rm = "echo 'Stop using rm, use tp (or trash-put) instead'";

      copy = ''
        if [ "$argv" = "" ]
          fish_clipboard_copy
        else
          printf "$argv" | fish_clipboard_copy
        end
      '';
    };
  };

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
