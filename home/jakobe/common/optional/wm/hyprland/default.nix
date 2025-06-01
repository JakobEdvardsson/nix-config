{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.customHome.hyprland;
  selectedBar = cfg.bar; # Extract the bar value into a variable
in
{
  options.customHome.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland as the window manager for Wayland.";

    monitor = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = ''
        Path to monitor config
      '';
    };

    nvidia = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable Nvidia option for hyprland. Offload render to gpu";
    };

  };

  imports = [
    ./config
    ./scripts
  ];

  config = lib.mkIf cfg.enable {
    # Dependencies for hyprland
    customHome = {
      waybar.enable = lib.mkDefault true;
      rofi-wayland.enable = lib.mkDefault true;
      hyprlock.enable = lib.mkDefault true;
      hypridle.enable = lib.mkDefault true;
      swaync.enable = lib.mkDefault true;
      polkit.enable = lib.mkDefault true;
    };

    # required packages for Hyprland
    home.packages = with pkgs; [
      kitty
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd = {
        enable = true;
        variables = [
          "--all"
        ]; # fix for https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
        # TODO:(hyprland) experiment with whether this is required.
        # Same as default, but stop the graphical session too
        extraCommands = lib.mkBefore [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };

      settings = {
        exec-once = [ ];
        # Monitor, more at the bottom of this file:

        source = [ "./monitor.conf" ];

        #
        # ========== Environment Vars ==========
        #
        env = lib.concatLists [
          [

            "AQ_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0" # fixes screen tearing
            "GDK_BACKEND,wayland,x11,*"
            "QT_QPA_PLATFORM,wayland;xcb"
            "CLUTTER_BACKEND,wayland"

            #Run SDL2 applications on Wayland.
            #Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
            #"SDL_VIDEODRIVER,wayland"

            # xdg Specifications
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"

            # QT Variables
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORMTHEME,qt5ct"
            "QT_QPA_PLATFORMTHEME,qt6ct"

            # hyprland-qt-support
            "QT_QUICK_CONTROLS_STYLE,org.hyprland.style"

            # xwayland apps scale fix (useful if you are use monitor scaling).
            # Set same value if you use scaling in Monitors.conf
            # 1 is 100% 1.5 is 150%
            # see https://wiki.hyprland.org/Configuring/XWayland/
            "GDK_SCALE,1.5"
            "QT_SCALE_FACTOR,1.5"

            # firefox
            "MOZ_ENABLE_WAYLAND,1"

            # electron >28 apps (may help) ##
            # https://www.electronjs.org/docs/latest/api/environment-variables
            "ELECTRON_OZONE_PLATFORM_HINT,auto" # auto selects Wayland if possible, X11 otherwise
          ]
          (
            if cfg.nvidia then
              [

                "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1" #https://github.com/hyprwm/aquamarine/issues/171
                # "LIBVA_DRIVER_NAME,nvidia"
                # "__GLX_VENDOR_LIBRARY_NAME,nvidia"
                # "NVD_BACKEND,direct"
                # ""
                #
                # # additional ENV's for nvidia. Caution, activate with care
                # "GBM_BACKEND,nvidia-drm"
                #
                # "__GL_GSYNC_ALLOWED,1" # adaptive Vsync
                # "__NV_PRIME_RENDER_OFFLOAD,1"
                # "__VK_LAYER_NV_optimus,NVIDIA_only"
                # "WLR_DRM_NO_ATOMIC,1"
                #
                # # FOR VM and POSSIBLY NVIDIA
                # # LIBGL_ALWAYS_SOFTWARE software mesa rendering
                # #"LIBGL_ALWAYS_SOFTWARE,1" # Warning. May cause hyprland to crash
                # "WLR_RENDERER_ALLOW_SOFTWARE,1"
                #
                # # nvidia firefox (for hardware acceleration on FF)?
                # # check this post https://github.com/elFarto/nvidia-vaapi-driver#configuration
                # "MOZ_DISABLE_RDD_SANDBOX,1"
                # "EGL_PLATFORM,wayland"
              ]
            else
              [ ]
          )
        ];
      };
    };
    xdg = {
      configFile = {
        "hypr/monitor.conf".source = config.lib.file.mkOutOfStoreSymlink "${cfg.monitor}";
      };
    };
  };
}
