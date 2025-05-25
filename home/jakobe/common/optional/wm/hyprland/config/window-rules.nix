{
  pkgs,
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    #
    # ========== Window Rules ==========
    #
    windowrule = [
      #windowrule = noblur,gamescope
      #windowrule = fullscreen,gamescope
      #windowrule = workspace 6 silent,^(gamescope)$

      # windowrule Position
      "center,^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)"
      "center,^([Ww]hatsapp-for-linux)$"
      "center,^([Ff]erdium)$"

      # Dialogs
      "float, title:^(Open File)(.*)$"
      "float, title:^(Select a File)(.*)$"
      "float, title:^(Choose wallpaper)(.*)$"
      "float, title:^(Open Folder)(.*)$"
      "float, title:^(Save As)(.*)$"
      "float, title:^(Library)(.*)$"
      "float, title:^(Accounts)(.*)$"
    ];
    # WINDOWRULE v2
    windowrulev2 = [
      # windowrule v2 - position
      #  center,floating:1 # warning, it cause even the menu to float and center.
      "center, class:([Tt]hunar), title:(File Operation Progress)"
      "center, class:([Tt]hunar), title:(Confirm to replace files)"
      "move 72% 7%,title:^(Picture-in-Picture)$"
      # move 72% 7%,title:^(Firefox)$

      # windowrule v2 to avoid idle for fullscreen apps
      "idleinhibit fullscreen, class:^(*)$"
      "idleinhibit fullscreen, title:^(*)$"
      "idleinhibit fullscreen, fullscreen:1"

      # windowrule v2 move to workspace
      "workspace 1, class:^([Tt]hunderbird)$"

      "workspace 1, class:^(VSCode|code-url-handler)$"
      "workspace 1, class:^(zed|dev.zed.Zed)$"
      "workspace 1, class:^(jetbrains-.+)$ # JetBrains IDEs"

      "workspace 2, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$"
      "workspace 2, class:^(brave-browser)$"
      "workspace 2, class:^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable)?)$"
      "workspace 2, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
      # workspace 3, class:^([Tt]hunar)$
      "workspace 4, class:^(com.obsproject.Studio)$"
      "workspace 5, class:^([Ss]team)$"
      "workspace 5, class:^([Ll]utris)$"
      "workspace 7, class:^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
      "workspace 7, class:^([Ff]erdium)$"
      "workspace 7, class:^([Ww]hatsapp-for-linux)$"

      # windowrule v2 move to workspace (silent)
      "workspace 6 silent, class:^(virt-manager)$"
      "workspace 9 silent, class:^([Aa]udacious)$"

      # windowrule v2 - float
      "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
      "float, class:([Zz]oom|onedriver|onedriver-launcher)$"
      "float, class:([Tt]hunar), title:(File Operation Progress)"
      "float, class:([Tt]hunar), title:(Confirm to replace files)"
      "float, class:(xdg-desktop-portal-gtk)"
      "float, class:(org.gnome.Calculator), title:(Calculator)"
      "float, class:(codium|codium-url-handler|VSCodium), title:(Add Folder to Workspace)"
      "float, class:^([Rr]ofi)$"
      "float, class:^(eog|org.gnome.Loupe)$ # image viewer"
      "float, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
      "float, class:^(nwg-look|qt5ct|qt6ct)$"
      "float, class:^(mpv|com.github.rafostar.Clapper)$"
      "float, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
      "float, class:^(gnome-system-monitor|org.gnome.SystemMonitor)$ # system monitor"
      "float, class:^(yad)$ # icon browser"
      "float, class:^(wihotspot(-gui)?)$ # wifi hotspot"
      "float, class:^(evince)$ # document viewer"
      "float, class:^(file-roller|org.gnome.FileRoller)$ # archive manager"
      "float, class:^([Bb]aobab|org.gnome.[Bb]aobab)$ # Disk usage analyzer"
      "float, title:(Kvantum Manager)"
      "float, class:^([Ss]team)$,title:^((?![Ss]team).*|[Ss]team [Ss]ettings)$"
      "float, class:^([Qq]alculate-gtk)$"
      "float, class:^([Ww]hatsapp-for-linux)$"
      "float, class:^([Ff]erdium)$"
      "float, title:^(Picture-in-Picture)$"
    ];
  };
}
