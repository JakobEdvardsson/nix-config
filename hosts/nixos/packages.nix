{pkgs, pkgs-stable, ...}:
  let
    python-packages = pkgs.python3.withPackages (
      ps:
        with ps; [
          requests
          pyquery # needed for hyprland-dots Weather script
          ]
      );
  in {

    environment.systemPackages = (with pkgs-stable; [ 
    # Stable
    # firefox
  ]) ++ (with pkgs; [
    # Unstable
    # System Packages
    baobab
    btrfs-progs
    clang
    curl
    cpufrequtils
    duf
    eza
    ffmpeg   
    glib #for gsettings to work
    gsettings-qt
    git
    killall  
    libappindicator
    libnotify
    openssl #required by Rainbow borders
    pciutils
    vim
    wget
    xdg-user-dirs
    xdg-utils

    fastfetch
    (mpv.override {scripts = [mpvScripts.mpris];}) # with tray
    #ranger
   
    # Code
    zed-editor
    vscode-fhs
    go
    nodejs_22
    neovim
    tmux
    gh
    github-desktop

   
    # Hyprland/Dotfiles Stuff
    ags        
    btop
    cava
    cliphist
    eog
    gnome-system-monitor
    file-roller
    grim
    gtk-engine-murrine #for gtk themes
    hyprcursor # requires unstable channel
    hypridle # requires unstable channel
    imagemagick 
    inxi
    jq
    kitty
    libsForQt5.qtstyleplugin-kvantum #kvantum
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
    qt6Packages.qtstyleplugin-kvantum #kvantum
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

    python-packages
    #waybar  # if wanted experimental next line
    #(pkgs.waybar.overrideAttrs (oldAttrs: { mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];}))
  ]);
  
}

