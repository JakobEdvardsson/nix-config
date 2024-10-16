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

      #neovim
      neovim
      lazygit
      ripgrep
      fd

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
      kitty
      libsForQt5.qtstyleplugin-kvantum # kvantum
      networkmanagerapplet
      nwg-look # requires unstable channel
      nvtopPackages.full
      pamixer
      pavucontrol
      playerctl
      polkit_gnome
      pyprland
      qt5ct
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
      lsd
      oh-my-posh
      unzip
      zoxide

      python-packages
      #waybar  # if wanted experimental next line
      #(pkgs.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];}))
    ]);

}
