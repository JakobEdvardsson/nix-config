{
  pkgs,
  config,
  lib,
  ...
}:
{

  wayland.windowManager.hyprland.settings = {
    #
    # ========== Gestures ==========
    #
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
      workspace_swipe_distance = 500;
      workspace_swipe_invert = true;
      workspace_swipe_min_speed_to_force = 30;
      workspace_swipe_cancel_ratio = 0.5;
      workspace_swipe_create_new = true;
      workspace_swipe_forever = true;
      #workspace_swipe_use_r = true #uncomment if wanted a forever create a new workspace with swipe right
    };
  };
}
