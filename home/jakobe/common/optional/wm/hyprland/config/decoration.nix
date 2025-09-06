{ pkgs, config, lib, ... }: {
  wayland.windowManager.hyprland.settings = {
    #
    # ========== Appearance ==========
    #
    decoration = {
      active_opacity = 1.0;
      inactive_opacity = 0.97;
      fullscreen_opacity = 1.0;
      rounding = 10;
      blur = {
        enabled = false;
        size = 5;
        passes = 3;
        new_optimizations = true;
        popups = true;
      };
      shadow = {
        enabled = true;
        range = 12;
        offset = "3 3";
        #color = "0x88ff9400";
        #color_inactive = "0x8818141d";
      };
    };
  };
}
