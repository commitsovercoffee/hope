if status is-interactive
    # Commands to run in interactive sessions can go here
end

# navigation -------------------------------------------------------------------

alias ls="exa"
alias cat=bat
alias mkdir='mkdir -pv'
alias grep='grep --color=auto'
alias open="xdg-open"

# pacman -----------------------------------------------------------------------

alias sync="sudo pacman -Syy"
alias update="sudo pacman -Syu"
alias info="sudo pacman -Ss"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"

# custom -----------------------------------------------------------------------

alias vim=nvim
alias top=btop
alias bye="sudo rsync -r --delete ~/Documents ~/Sync ~/Zion/Backup; sleep 2; sudo updatedb; sleep 2; clear; cowsay 'see ya!'; sleep 2; poweroff"

function weather
    curl "wttr.in/$argv?format=3"
end

# start X at login.
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
    end
end

starship init fish | source
set fish_greeting
