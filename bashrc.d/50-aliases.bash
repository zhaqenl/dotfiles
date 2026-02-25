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
alias xc='wl-copy'

# Resolve hostname to IP and copy to clipboard
hc() {
    local ip
    ip=$(host "$1" | awk '/has address/ {print $4; exit}')
    if [ -n "$ip" ]; then
        echo "$ip" | wl-copy
        echo "$ip"
    else
        echo "No address found for $1" >&2
    fi
}

# Odoo-specific ripgrep (excludes translation files)
alias rgo="rg -S --glob '!*.po'"

# Start Google Workspace MCP server for timesheet logging
alias timesheet-mcp='uv run main.py --transport streamable-http --tools chat contacts calendar --tool-tier extended'

# Expose local port via pinggy.io tunnel
pinggy() {
    ssh -p 443 -R0:localhost:$1 free.pinggy.io
}
