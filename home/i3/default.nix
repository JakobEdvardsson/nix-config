{
  pkgs,
  config,
  ...
}: {
  # i3 配置，基于 https://github.com/endeavouros-team/endeavouros-i3wm-setup
  # 直接从当前文件夹中读取配置文件作为配置内容

  # wallpaper, binary file
  home.file."Pictures/Wallpaper" = {
    source = ../../wallpaper;
    recursive = true;
  };

  home.file.".config/i3/config".source = ./config;
  home.file.".config/i3/i3blocks.conf".source = ./i3blocks.conf;
  home.file.".config/i3/keybindings".source = ./keybindings;
  home.file.".config/i3/scripts" = {
    source = ./scripts;
    # copy the scripts directory recursively
    recursive = true;
    executable = true;  # make all scripts executable
  };


  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 24;
    "Xft.dpi" = 144;
  };



}