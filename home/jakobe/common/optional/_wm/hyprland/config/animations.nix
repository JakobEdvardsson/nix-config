{ pkgs, config, lib, ... }: {
  wayland.windowManager.hyprland.settings = {
    #
    # ========== Aanimation ==========
    #
    animations = {
      enabled = true;

      animation = [
        "windows, 1, 3, default"
        "layers, 1, 3, default"
        "fade, 1, 3, default"
        "workspaces, 1, 3, default"
      ];
    };
  };
}
