{ pkgs, pkgs-stable, ... }:
{

  environment.systemPackages =
    (with pkgs-stable; [
      # Stable
      # firefox
    ])
    ++ (with pkgs; [
      # Unstable
      # Applications
      vesktop
      spotify
      gimp
      inkscape
      brave
      flameshot
      onlyoffice-bin
      thonny
      teams-for-linux
      zoom-us
      obs-studio
      samba

      # Hacking
      thc-hydra
      seclists
      metasploit
      gobuster
      gospider
      nmap
      wireshark
      tcpdump

      # Embedded / coding
      avra
      avrdude
      #avrlibc
      clang
      jetbrains.idea-ultimate
      jetbrains.jdk
      simavr

      # System Packages
      baobab
      btrfs-progs
      clang
      curl
      cpufrequtils
      duf
      eza
      ffmpeg
      glib # for gsettings to work
      gsettings-qt
      git
      killall
      libappindicator
      libnotify
      openssl # required by Rainbow borders
      pciutils
      vim
      wget
      xdg-user-dirs
      xdg-utils
      tree
      usbutils
      home-manager
      openvpn

      fastfetch
      (mpv.override { scripts = [ mpvScripts.mpris ]; }) # with tray
      #ranger

      # Code
      zed-editor
      vscode-fhs
      go
      nodejs_22
      tmux
      gh
      github-desktop
      android-tools

      # Terminal
      neovim
      lazygit
      ripgrep
      fd
      zoxide
      oh-my-posh
      kitty
      lsd
      starship
      yazi
    ]);

}
