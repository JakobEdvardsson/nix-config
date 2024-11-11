{ pkgs, pkgs-stable, ... }:
let
  python-packages = pkgs.python3.withPackages (
    ps: with ps; [
      requests
      pyquery # needed for hyprland-dots Weather script
    ]
  );
in
{

  environment.systemPackages =
    (with pkgs-stable; [
      # Stable
      cliphist
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

      # Hyprland/Dotfiles Stuff
      brightnessctl
      ags
      btop
      cava
      eog
      gnome-system-monitor
      file-roller
      grim
      gtk-engine-murrine # for gtk themes
      hyprcursor # requires unstable channel
      hypridle # requires unstable channel
      imagemagick
      inxi
      jq
      libsForQt5.qtstyleplugin-kvantum # kvantum
      networkmanagerapplet
      nwg-look # requires unstable channel
      nvtopPackages.full
      pamixer
      pavucontrol
      playerctl
      polkit_gnome
      pyprland
      libsForQt5.qt5ct
      qt6ct
      qt6.qtwayland
      qt6Packages.qtstyleplugin-kvantum # kvantum
      rofi-wayland
      slurp
      swappy
      swaynotificationcenter
      swww
      unzip
      wallust
      wl-clipboard
      wlogout
      yad
      yt-dlp
      stow
      unzip

      python-packages
      #waybar  # if wanted experimental next line
      #(pkgs.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];}))
    ]);

}
