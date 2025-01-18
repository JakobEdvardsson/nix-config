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
    escapeTime = 100;

    plugins = with pkgs.tmuxPlugins; [
      fzf-tmux-url
      tmux-fzf
      tmux-yank
      sensible
      {
        plugin = tmux-resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmux-continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
      {
        plugin = better-mouse-mode;
        extraConfig = "set -g mouse on";
      }
      {
        plugin = vim-tmux-navigator;
        extraConfig = "
          set -g @vim_navigator_mapping_left 'M-Left'
          set -g @vim_navigator_mapping_right 'M-Right'
          set -g @vim_navigator_mapping_up 'M-Up'
          set -g @vim_navigator_mapping_down 'M-Down'
          ";
      }

    ];
    extraConfig = ''
      set -g base-index 1              # start indexing windows at 1 instead of 0
      set -g detach-on-destroy off     # don't exit from tmux when closing a session
      set -g escape-time 0             # zero-out escape time delay
      set -g renumber-windows on       # renumber all windows when any window is closed
      set -g set-clipboard on          # use system clipboard

      ###################
      #      Binds      #
      ###################

      bind c new-window -c '#{pane_current_path}'
      bind s choose-session
      bind p previous-window
      bind n next-window
      bind * list-clients
      bind p previous-window
      bind n next-window
      bind r command-prompt 'rename-window %%'
      bind R source-file ~/.config/tmux/tmux.conf \; display "Reloaded!" # quick reload
      bind w list-windows
      bind m copy-mode
      bind q kill-pane
      bind x swap-pane -D
      bind-key -T copy-mode-vi v send-keys -X begin-selection

      bind j choose-window 'join-pane -h -s "%%"'
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind z resize-pane -Z
      bind '"' choose-window










    '';
  };
}
