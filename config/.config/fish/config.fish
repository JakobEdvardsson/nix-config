
# ----------------------------
# ███████╗██╗███████╗██╗  ██╗
# ██╔════╝██║██╔════╝██║  ██║
# █████╗  ██║███████╗███████║
# ██╔══╝  ██║╚════██║██╔══██║
# ██║     ██║███████║██║  ██║
# ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
# ----------------------------                          

if status is-interactive
    # -------------------------
    # OH MY POSH CONFIGURATION
    # -------------------------
    #oh-my-posh init fish --config ~/.config/oh-my-posh/config.json | source

    # -------------------------
    # STARSHIP CONFIGURATION
    # -------------------------
    starship init fish | source

    zoxide init fish | source

    # --------------------
    # REMOVE INTRO MESSAGE
    # --------------------
    set fish_greeting

    set -q XDG_CONFIG_HOME || set XDG_CONFIG_HOME "$HOME/.config"
    source $XDG_CONFIG_HOME/fish/tokyonight.fish
    source $XDG_CONFIG_HOME/fish/aliases.fish


    # --------
    # ALIASES
    # --------
    alias ls="lsd"
    alias c="clear"
    alias f="firefox"
    alias cd="z"


end


# if test -n "$TMUX"
#     set -gx TERM screen-256color
# end
