{ pkgs, config, lib, ... }: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "tag +browser, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$"
      "tag +browser, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$"
      "tag +browser, class:^(chrome-.+-Default)$ # Chrome PWAs"
      "tag +browser, class:^([Cc]hromium)$"
      "tag +browser, class:^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$"
      "tag +browser, class:^(Brave-browser(-beta|-dev|-unstable)?)$"
      "tag +browser, class:^([Tt]horium-browser|[Cc]achy-browser)$"
      "tag +browser, class:^(zen-alpha|zen)$"

      # notif tags
      "tag +notif, class:^(swaync-control-center|swaync-notification-window|swaync-client|class)$"

      # KooL settings tag
      "tag +KooL_Cheat, title:^(KooL Quick Cheat Sheet)$"
      "tag +KooL_Settings, title:^(KooL Hyprland Settings)$"
      "tag +KooL-Settings, class:^(nwg-displays|nwg-look)$"

      # terminal tags
      "tag +terminal, class:^(Alacritty|kitty|kitty-dropterm)$"

      # email tags
      "tag +email, class:^([Tt]hunderbird|org.gnome.Evolution)$"
      "tag +email, class:^(eu.betterbird.Betterbird)$"

      # project tags
      "tag +projects, class:^(codium|codium-url-handler|VSCodium)$"
      "tag +projects, class:^(VSCode|code-url-handler)$"
      "tag +projects, class:^(jetbrains-.+)$ # JetBrains IDEs"

      # screenshare tags
      "tag +screenshare, class:^(com.obsproject.Studio)$"

      # IM tags
      "tag +im, class:^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$"
      "tag +im, class:^([Ff]erdium)$"
      "tag +im, class:^([Ww]hatsapp-for-linux)$"
      "tag +im, class:^(ZapZap|com.rtosta.zapzap)$ "
      "tag +im, class:^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$"
      "tag +im, class:^(teams-for-linux)$"

      # game tags
      "tag +games, class:^(gamescope)$"
      "tag +games, class:^(steam_app_d+)$"

      # gamestore tags
      "tag +gamestore, class:^([Ss]team)$"
      "tag +gamestore, title:^([Ll]utris)$"
      "tag +gamestore, class:^(com.heroicgameslauncher.hgl)$"

      # file-manager tags
      "tag +file-manager, class:^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$"
      "tag +file-manager, class:^(app.drey.Warp)$"

      # wallpaper tags
      "tag +wallpaper, class:^([Ww]aytrogen)$"

      # multimedia tags
      "tag +multimedia, class:^([Aa]udacious)$"

      # multimedia-video tags
      "tag +multimedia_video, class:^([Mm]pv|vlc)$"

      # settings tags
      "tag +settings, title:^(ROG Control)$"
      "tag +settings, class:^(wihotspot(-gui)?)$ # wifi hotspot"
      "tag +settings, class:^([Bb]aobab|org.gnome.[Bb]aobab)$ # Disk usage analyzer"
      "tag +settings, class:^(gnome-disks|wihotspot(-gui)?)$"
      "tag +settings, title:(Kvantum Manager)"
      "tag +settings, class:^(file-roller|org.gnome.FileRoller)$ # archive manager"
      "tag +settings, class:^(nm-applet|nm-connection-editor|blueman-manager)$"
      "tag +settings, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
      "tag +settings, class:^(qt5ct|qt6ct|[Yy]ad)$"
      "tag +settings, class:(xdg-desktop-portal-gtk)"
      "tag +settings, class:^(org.kde.polkit-kde-authentication-agent-1)$"
      "tag +settings, class:^([Rr]ofi)$"

      # viewer tags
      "tag +viewer, class:^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$ # system monitor"
      "tag +viewer, class:^(evince)$ # document viewer "
      "tag +viewer, class:^(eog|org.gnome.Loupe)$ # image viewer"

      # Some special override rules
      "noblur, tag:multimedia_video*"
      "opacity 1.0, tag:multimedia_video*"

      # POSITION
      # "center,floating:1 # warning, it cause even the menu to float and center.
      "center, tag:KooL_Cheat*"
      "center, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"
      "center, title:^(ROG Control)$"
      "center, tag:KooL-Settings*"
      "center, title:^(Keybindings)$"
      "center, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$"
      "center, class:^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$"
      "center, class:^([Ff]erdium)$"
      "move 72% 7%,title:^(Picture-in-Picture)$ "
      #"move 72% 7%,title:^(Firefox)$

      # windowrule to avoid idle for fullscreen apps
      #"idleinhibit fullscreen, class:^(*)$
      #"idleinhibit fullscreen, title:^(*)$
      "idleinhibit fullscreen, fullscreen:1"

      # windowrule move to workspace
      "workspace 1, tag:email*"
      "workspace 2, tag:browser*"
      #"workspace 3, class:^([Tt]hunar)$"
      #"workspace 3, tag:projects*
      "workspace 5, tag:gamestore*"
      "workspace 7, tag:im*"
      "workspace 8, tag:games*"

      # windowrule move to workspace (silent)
      "workspace 4 silent, tag:screenshare*"
      "workspace 6 silent, class:^(virt-manager)$"
      "workspace 6 silent, class:^(.virt-manager-wrapped)$"
      "workspace 9 silent, tag:multimedia*"

      # FLOAT
      "float, tag:KooL_Cheat*"
      "float, tag:wallpaper*"
      "float, tag:settings*"
      "float, tag:viewer*"
      "float, tag:KooL-Settings*"
      "float, class:([Zz]oom|onedriver|onedriver-launcher)$"
      "float, class:(org.gnome.Calculator), title:(Calculator)"
      "float, class:^(mpv|com.github.rafostar.Clapper)$"
      "float, class:^([Qq]alculate-gtk)$"
      #"float, class:^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$
      "float, class:^([Ff]erdium)$"
      "float, title:^(Picture-in-Picture)$"
      #"float, title:^(Firefox)$

      # windowrule - ######### float popups and dialogue #######
      "float, title:^(Authentication Required)$"
      "center, title:^(Authentication Required)$"
      "float, class:(codium|codium-url-handler|VSCodium), title:negative:(.*codium.*|.*VSCodium.*)"
      "float, class:^(com.heroicgameslauncher.hgl)$, title:negative:(Heroic Games Launcher)"
      "float, class:^([Ss]team)$, title:negative:^([Ss]team)$"
      "float, class:([Tt]hunar), title:negative:(.*[Tt]hunar.*)"

      "float, title:^(Add Folder to Workspace)$"
      "size 70% 60%, title:^(Add Folder to Workspace)$"
      "center, title:^(Add Folder to Workspace)$"

      "float, title:^(Save As)$"
      "size 70% 60%, title:^(Save As)$"
      "center, title:^(Save As)$"

      "float, initialTitle:(Open Files)"
      "size 70% 60%, initialTitle:(Open Files)"

      "float, title:^(SDDM Background)$ #KooL's Dots YAD for setting SDDM background"
      "center, title:^(SDDM Background)$ #KooL's Dots YAD for setting SDDM background"
      "size 16% 12%, title:^(SDDM Background)$ #KooL's Dots YAD for setting SDDM background"
      # END of float popups and dialogue #######

      # SIZE
      "size 65% 90%, tag:KooL_Cheat*"
      "size 70% 70%, tag:wallpaper*"
      "size 70% 70%, tag:settings*"
      "size 60% 70%, class:^([Ww]hatsapp-for-linux|ZapZap|com.rtosta.zapzap)$"
      "size 60% 70%, class:^([Ff]erdium)$"

      #"size 25% 25%, title:^(Picture-in-Picture)$
      #"size 25% 25%, title:^(Firefox)$

      # PINNING
      "pin, title:^(Picture-in-Picture)$"
      #"pin,title:^(Firefox)$

      # windowrule - extras
      "keepaspectratio, title:^(Picture-in-Picture)$"

      # BLUR & FULLSCREEN
      "noblur, tag:games*"
      "fullscreen, tag:games*"

      #"bordercolor rgb(EE4B55) rgb(880808), fullscreen:1
      #"bordercolor rgb(282737) rgb(1E1D2D), floating:1
      #"opacity 0.8 0.8, pinned:1
    ];
  };
}
