{
  pkgs,
  lib,
  config,
  ...
}:

{
  # required packages for Waybar
  home.packages = with pkgs; [
    # Audio
    playerctl
    pamixer
    pavucontrol

    # Network
    networkmanagerapplet

  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style =
      with config.lib.stylix.colors.withHashtag;
      ''
        @define-color base00 ${base00}; @define-color base01 ${base01}; @define-color base02 ${base02}; @define-color base03 ${base03};
        @define-color base04 ${base04}; @define-color base05 ${base05}; @define-color base06 ${base06}; @define-color base07 ${base07};

        @define-color base08 ${base08}; @define-color base09 ${base09}; @define-color base0A ${base0A}; @define-color base0B ${base0B};
        @define-color base0C ${base0C}; @define-color base0D ${base0D}; @define-color base0E ${base0E}; @define-color base0F ${base0F};
      ''
      + builtins.readFile ./style.css;
    settings = {
      bar = {
        layer = "top";
        position = "top";
        spacing = 0;
        height = 30;
        modules-left = [
          "custom/logo"
          "hyprland/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "tray"
          "memory"
          "network"
          "wireplumber"
          "battery"
          "custom/power"
        ];
        hyprland.workspaces = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            default = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            urgent = " ";
          };
        };
        memory = {
          interval = 5;
          format = "󰍛 {}%";
          max-length = 10;
        };
        tray = {
          spacing = 10;
        };
        clock = {
          tooltip-format = "{calendar}";
          format-alt = "  {:%a, %d %b %Y}";
          format = "  {:%H:%M}";
        };
        network = {
          format-wifi = "{icon}";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = "󰌘";
          format-disconnected = "󰖪";
          tooltip-format-wifi = "{icon} {essid}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "󰀂  {ifname}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "nm-connection-editor & ";
          on-click-right = "${config.home.sessionVariables.TERMINAL} nmtui &";
          interval = 5;
          nospacing = 1;
        };
        wireplumber = {
          format = "{icon}  {volume} %";
          format-bluetooth = "󰂰";
          nospacing = 1;
          tooltip-format = "Volume : {volume}%";
          format-muted = "󰝟";
          format-icons = {
            headphone = "";
            default = [
              "󰖀"
              "󰕾"
              ""
            ];
          };
          on-click = "pavucontrol -t 3";
          on-click-right = "pamixer -t";

          scroll-step = 1;
        };
        "custom/logo" = {
          format = "  ";
          tooltip = false;
          on-click = "${config.home.sessionVariables.BROWSER} https://home-manager-options.extranix.com/ &&
            ${config.home.sessionVariables.BROWSER} https://search.nixos.org/packages & "; # Open nixos and homemanager search
        };
        battery = {
          format = "{capacity}% {icon}";
          format-icons = {
            charging = [
              "󰢜"
              "󰂆"
              "󰂇"
              "󰂈"
              "󰢝"
              "󰂉"
              "󰢞"
              "󰂊"
              "󰂋"
              "󰂅"
            ];
            default = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
          format-full = "Charged ";
          interval = 5;
          states = {
            warning = 20;
            critical = 10;
          };
          tooltip = false;
        };
        "custom/power" = {
          format = "󰤆";
          tooltip = false;
          on-click = "powermenu &";
        };
      };
    };
  };
}
