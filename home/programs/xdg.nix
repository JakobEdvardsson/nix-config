{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (pkgs) writeText;
  inherit (lib.strings) concatStringsSep;
  inherit (config) xdg;

  browser = ["firefox.desktop"];

  # XDG MIME types
  associations = {
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "text/html" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/chrome" = ["chromium-browser.desktop"];
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/unknown" = browser;

    "audio/*" = ["mpv.desktop"];
    "video/*" = ["mpv.dekstop"];
    "image/*" = ["imv.desktop"];
    "application/json" = browser;
    "application/pdf" = ["org.pwmt.zathura.desktop.desktop"];
    "x-scheme-handler/discord" = ["discordcanary.desktop"];
    "x-scheme-handler/spotify" = ["spotify.desktop"];
    "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
  };
in {
  xdg.userDirs = {
    enable = true;
    # Work around firefox creating a "Desktop" directory
    desktop = "${config.home.homeDirectory}";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    music = "${config.xdg.userDirs.documents}/Music";
    videos = "${config.xdg.userDirs.documents}/Videos";
    pictures = "${config.xdg.userDirs.documents}/Pictures";
    publicShare = "${config.xdg.userDirs.documents}/Public";
    templates = "${config.xdg.userDirs.documents}/Templates";
    extraConfig = {
      XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = associations;
  };

  home.sessionVariables = {
    _JAVA_OPTIONS = concatStringsSep " " [
      "-Djava.util.prefs.userRoot='${xdg.configHome}'/java"
      "-Djavafx.cachedir='${xdg.cacheHome}/openjfx'"
    ];
    PYLINTHOME = "${xdg.cacheHome}/pylint";
    CARGO_HOME = "${xdg.cacheHome}/cargo";
    RUSTUP_HOME = "${xdg.dataHome}/rustup";
    XCOMPOSECACHE = "${xdg.cacheHome}/X11/xcompose";
    XCOMPOSEFILE = "${xdg.configHome}/X11/xcompose";
    MAILCAPS = "${xdg.configHome}/mailcap";
    IPYTHONDIR = "${xdg.dataHome}/ipython";
    JUPYTER_CONFIG_DIR = "${xdg.dataHome}/ipython";
    HISTFILE = "${xdg.dataHome}/histfile";
    RLWRAP_HOME = "${xdg.dataHome}/rlwrap"; # stumpish and perhaps others
    CUDA_CACHE_PATH = "${xdg.dataHome}/cuda";

    # See, this is exactly why things should follow the spec. I have
    # no intention of using gradle ever, but occasionally I need to
    # build software that uses it.
    #
    # Now I need to deal with gradle puking directories all over my
    # file system, or have a permanent configuration option here for
    # software I don't even use.
    #
    # Grmbl.
    GRADLE_USER_HOME = "${xdg.cacheHome}/gradle";

    NPM_CONFIG_USERCONFIG = writeText "npmrc" ''
      prefix=${xdg.cacheHome}/npm
      cache=${xdg.cacheHome}/npm
      tmp=$XDG_RUNTIME_DIR/npm
      init-module=${xdg.configHome}/npm/config/npm-init.js
    '';

  };
}
