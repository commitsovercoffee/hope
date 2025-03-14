if status is-interactive
    # Commands to run in interactive sessions can go here
end

# General :
alias cat=bat
alias ls="exa -l"
alias open="xdg-open"
alias vim=nvim
alias top=btop
alias bye="sudo rsync -r ~/Obsidian ~/Zion/Blue/; shutdown -h now"
function weather
    curl "wttr.in/$argv?format=3"
end

alias mkdir='mkdir -pv'
alias grep='grep --color=auto'

# Pacman : 
alias sync="sudo pacman -Syy"
alias update="sudo pacman -Syu"
alias info="sudo pacman -Ss"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"

# Git 
alias stats="git status"
alias add="git add ."
alias commit="git commit -m"
alias push="git push"

# start X at login
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec startx -- -keeptty
    end
end

starship init fish | source
set fish_greeting
