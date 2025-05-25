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

    #TODO:
    # Nvidia options
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
            "NIXOS_OZONE_WL,1" # For ozone-based and Electron apps
            "MOZ_ENABLE_WAYLAND,1" # For Firefox Wayland
            "MOZ_WEBRENDER,1" # For Firefox Wayland
            "XDG_SESSION_TYPE,wayland"
            "WLR_NO_HARDWARE_CURSORS,1"
            "WLR_RENDERER_ALLOW_SOFTWARE,1"
            "QT_QPA_PLATFORM,wayland"
          ]
          (
            if cfg.nvidia then
              [
                "LIBVA_DRIVER_NAME,nvidia"
                "__GLX_VENDOR_LIBRARY_NAME,nvidia"
                "NVD_BACKEND,direct"
                # additional ENV's for nvidia. Caution, activate with care
                "GBM_BACKEND,nvidia-drm"
                "__NV_PRIME_RENDER_OFFLOAD,1"
                "__VK_LAYER_NV_optimus,NVIDIA_only"
                "WLR_DRM_NO_ATOMIC,1"
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
