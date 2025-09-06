{ pkgs, config, lib, ... }: {
  wayland.windowManager.hyprland.settings = {
    #
    # ========== Auto Launch ==========
    #
    # exec-once = ''${startupScript}/path'';
    # To determine path, run `which foo`
    exec-once = [
      /* ''${pkgs.waypaper}/bin/waypaper --restore''
         ''[workspace 0 silent]${pkgs.spotify}/bin/spotify''
         ''[workspace special silent]${pkgs.keymapp}/bin/keymapp''
      */
    ];
  };
}
