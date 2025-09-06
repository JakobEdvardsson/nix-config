{ pkgs, ... }: {
  services = {
    gnome.sushi.enable = true; # Quick preview with spacebar
    gvfs.enable = true; # for stuff like Trash folders etc
    udisks2.enable = true; # storage device manipulation
    devmon.enable = true;

    # thumbnails
    tumbler.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nautilus
    nautilus-python
    sushi
    file-roller
    simple-scan
    nautilus-open-any-terminal
    #https://itsfoss.com/nautilus-tips-tweaks/
    #nautilus-image-converter
    #folder-color
    #nautilus-admin
    #nautilus-gtkhash
    #nautilus-terminal

    # thumbnails
    gst_all_1.gst-libav
    ffmpegthumbnailer
  ];
  networking.firewall.extraCommands =
    "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
}
