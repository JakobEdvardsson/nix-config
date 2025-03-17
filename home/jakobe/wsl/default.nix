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
    development.enable = true;
    #tools.enable = true;
    #media.enable = true;
    #comms.enable = true;
    #browser.enable = true;
    #syncthing.enable = true;
  };
}
