{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    prefix = "C-s";
    terminal = "tmux-256color";
    historyLimit = 100000;
    clock24 = true;
    mouse = true;
    keyMode = "vi";
    newSession = true; # Automatically spawn a session if trying to attach and none are running.
    baseIndex = 1;

    plugins = with pkgs.tmuxPlugins; [
      fzf-tmux-url
      tmux-fzf
      yank
      sensible
      {
        plugin = resurrect;
        extraConfig = ''set -g @resurrect-strategy-nvim "session"'';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @continuum-restore 'on'
        '';
      }
      {
        plugin = better-mouse-mode;
        extraConfig = ''set -g mouse on'';
      }
      /*
        {

            plugin = vim-tmux-navigator;
            extraConfig = ''
              set -g @vim_navigator_mapping_left "C-Left"
              set -g @vim_navigator_mapping_right "C-Right"
              set -g @vim_navigator_mapping_up "C-Up"
              set -g @vim_navigator_mapping_down "C-Down"
              set -g @vim_navigator_mapping_prev ""
            '';
        }
      */

    ];
    extraConfig = ''
      set -g status-left "[#S]: "
      set -g status-left-length 30


      set -g detach-on-destroy off     # don't exit from tmux when closing a session
      set -g escape-time 0             # zero-out escape time delay
      set -g renumber-windows on       # renumber all windows when any window is closed
      set -g set-clipboard on          # use system clipboard
      set -g allow-passthrough all

      ###################
      #      Binds      #
      ###################


      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-Left' if-shell "$is_vim" 'send-keys C-Left'  'select-pane -L'
      bind-key -n 'C-Down' if-shell "$is_vim" 'send-keys C-Down'  'select-pane -D'
      bind-key -n 'C-Up' if-shell "$is_vim" 'send-keys C-Up'  'select-pane -U'
      bind-key -n 'C-Right' if-shell "$is_vim" 'send-keys C-Right'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind c new-window -c '#{pane_current_path}'
      bind C new-session -c '#{pane_current_path}'
      bind s choose-session
      bind p previous-window
      bind n next-window
      bind * list-clients
      bind p previous-window
      bind r command-prompt 'rename-window %%'
      bind R command-prompt 'rename-session %%'
      bind U source-file ~/.config/tmux/tmux.conf \; display "Reloaded!" # quick reload
      bind w list-windows
      bind m copy-mode
      bind q kill-pane
      bind Q kill-session
      bind x swap-pane -D
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind * setw synchronize-panes # Do the same command on all panes

      bind-key -n "M-Left" previous-window   # Switch to previous window
      bind-key -n "M-Right" next-window   # Switch to next window

      bind-key -n "M-Up" switch-client -p   # Switch to previous session
      bind-key -n "M-Down" switch-client -n   # Switch to next session

      bind-key Left swap-window -t -1\; select-window -t -1
      bind-key Right swap-window -t +1\; select-window -t +1

      bind j choose-window 'join-pane -h -s "%%"'
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind z resize-pane -Z
      bind '"' choose-window
    '';
  };
}
