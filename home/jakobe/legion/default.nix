{ config, ... }:
{
  imports = [
    #
    # ========== Required Configs ==========
    #
    ../common/core

    #
    # ========== Host-specific Optional Configs ==========
    #
    ../common/optional
  ];
  customHome = {
    hyprland = {
      enable = true;
      monitor = ./monitor.conf;
      nvidia = true;
    };
    development.enable = true;
    tools.enable = true;
    media.enable = true;
    comms.enable = true;
    browser.enable = true;
    syncthing.enable = true;

  };
  dconf = {
    enable = true;
    settings = {
      "com/github/stunkymonkey/nautilus-open-any-terminal" = {
        terminal = "kitty";
      };
    };
  };

}
