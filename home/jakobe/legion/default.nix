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
      nvidia = true;
    };
    programming.enable = true;
  };
}
