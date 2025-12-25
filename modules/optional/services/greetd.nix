# FIX: edit this
#
# greeter -> tuigreet https://github.com/apognu/tuigreet?tab=readme-ov-file
# display manager -> greetd https://man.sr.ht/~kennylevinsen/greetd/
#
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.customOption.greetd;
in
{
  options.customOption.greetd = {
    enable = lib.mkEnableOption "Enable greetd";
    autoLogin = {
      enable = lib.mkEnableOption "Enable automatic login";
      username = lib.mkOption {
        type = lib.types.str;
        default = "guest";
        description = "User to automatically login";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    #    environment.systemPackages = [ pkgs.greetd.tuigreet ];
    services.greetd = {
      enable = true;

      restart = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
          user = "ta";
        };

        initial_session = lib.mkIf cfg.autoLogin.enable {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = "${cfg.autoLogin.username}";
        };
      };
    };
  };
}
