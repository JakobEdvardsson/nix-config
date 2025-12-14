{ pkgs, config, lib, ... }: {
  wayland.windowManager.hyprland.settings = {
    input = {
      follow_mouse = 2;
      # follow_mouse options:
      # 0 - Cursor movement will not change focus.
      # 1 - Cursor movement will always change focus to the window under the cursor.
      # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
      # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
      mouse_refocus = false;

      kb_layout = "se";
      kb_variant = "";
      kb_model = "";
      kb_options = "";
      kb_rules = "";
      repeat_rate = 50;
      repeat_delay = 300;

      sensitivity = -0.2; # mouse sensitivity
      numlock_by_default = true;
      left_handed = false;
      float_switch_override_focus = false;

      touchpad = {
        disable_while_typing = true;
        natural_scroll = true;
        scroll_factor = 0.8;
        clickfinger_behavior = false;
        tap-to-click = true;
        drag_lock = false;
      };
    };

    cursor.inactive_timeout = 10;

    misc = {
      disable_hyprland_logo = true;
      animate_manual_resizes = true;
      animate_mouse_windowdragging = true;
      #disable_autoreload = true;
      new_window_takes_over_fullscreen =
        2; # 0 - behind, 1 - takes over, 2 - unfullscreen/unmaxize
      middle_click_paste = false;
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
      special_scale_factor = 0.8;
    };

    general = {
      layout = "dwindle";
      gaps_in = 6;
      gaps_out = 6;
      border_size = 2;
      resize_on_border = true;
      hover_icon_on_border = true;
      allow_tearing = true; # used to reduce latency and/or jitter in games
    };

    device = {
      name = "logitech-usb-receiver";
      sensitivity = -0.6;
    };
  };
}
