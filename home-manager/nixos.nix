{
  pkgs,
  ...
}:
{
  imports = [
    ./neovim.nix
  ];

  home = {
    username = "jakobe";
    homeDirectory = "/home/jakobe";
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # fix brave touchpad support. .desktop at /run/current-system/sw/share/applications/brave-browser.desktop
  xdg.desktopEntries.brave = {
    name = "Brave Way";
    genericName = "Brave Way";
    exec = "brave --enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform --ozone-platform=wayland";
    startupNotify = true;
    icon = "brave-browser";
    comment = "Access to the internet";
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "application/pdf"
      "application/rdf+xml"
      "application/rss+xml"
      "application/xhtml+xml"
      "application/xhtml_xml"
      "application/xml"
      "image/gif"
      "image/jpeg"
      "image/png"
      "image/webp"
      "text/html"
      "text/xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    #might need to add action
  };

  # home.file.".config/ags" = {
  #   source = ./config/ags;
  #   # copy the ags configuration directory recursively
  #   recursive = true;
  # };

  home.stateVersion = "24.05";
}
