# General aliases

# ls variants
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -lhFAtr'

# Desktop notification for long-running commands (usage: sleep 10; alert)
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias s='sudo'

# Emacs editor shortcuts
alias e='emacsclient -t'
export SUDO_EDITOR='emacsclient -t --alternate-editor='
alias es='sudo -e'

# Docker
alias dcu='docker compose down && docker compose up'
alias dcd='docker compose down'

# Misc utilities
alias mhost='make && python2.7 -m SimpleHTTPServer'
alias xc='xclip -sel clipboard'

# Odoo-specific ripgrep (excludes translation files)
alias rgo="rg -S --glob '!*.po'"

# Expose local port via pinggy.io tunnel
pinggy() {
    ssh -p 443 -R0:localhost:$1 free.pinggy.io
}
