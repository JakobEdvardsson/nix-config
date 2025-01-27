{ pkgs, ... }:
{
  programs.brave = {
    enable = true;
    commandLineArgs = [
      # "--no-default-browser-check"
      # "--restore-last-session"
      "--enable-features=TouchpadOverscrollHistoryNavigation,UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
  };

  programs.firefox.enable = true;

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "brave.desktop" ];
    "text/xml" = [ "brave.desktop" ];
    "x-scheme-handler/http" = [ "brave.desktop" ];
    "x-scheme-handler/https" = [ "brave.desktop" ];
  };

}
