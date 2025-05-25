{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.customHome.hyprlock;
in
{
  options.customHome.hyprlock = {
    enable = lib.mkEnableOption "Enable hyprlock as the lockscreen for Wayland.";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        background = {
          blur_passes = 3;
          blur_size = 5;
          brightness = 0.5;
          contrast = 1.0;
          noise = 2.0e-2;
        };

        input-field = {
          monitor = "";
          size = "250, 50";
          outline_thickness = 0;
          dots_size = 0.26;
          dots_spacing = 0.64;
          dots_center = true;
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          position = "0, 50";
          halign = "center";
          valign = "bottom";
        };
      };
      extraConfig = ''
        label {
            monitor =
            text = cmd[update:1000] echo "<b><big> $(date +"%H:%M") </big></b>"

            font_size = 64
            font_family = JetBrains Mono Nerd Font 10

            position = 0, 0
            halign = center
            valign = center
        }

        label {
            monitor =
            text = cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"

            font_size = 24
            font_family = JetBrains Mono Nerd Font 10

            position = 0, -80
            halign = center
            valign = center
        }
      '';
    };
  };
}
