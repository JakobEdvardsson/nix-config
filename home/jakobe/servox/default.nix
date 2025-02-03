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
  config.customHome = {
    hyprland = {
      enable = true;
      monitor = ./monitor.conf;
    };
    programming.enable = true;
    tools.enable = true;
    media.enable = true;
    comms.enable = true;
    browser.enable = true;
  };
}
