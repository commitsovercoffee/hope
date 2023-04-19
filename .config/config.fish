if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias cat=bat
alias ls="exa -l"
alias vim=nvim
alias cls=clear

# start X at login
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
    end
end
