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
alias dcl='docker compose ls'

# Misc utilities
alias mhost='make && python2.7 -m SimpleHTTPServer'
alias xc='wl-copy'

# Resolve hostname to IP and copy to clipboard
getip() {
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
alias timesheet-mcp='cd /home/lenovo/google_workspace_mcp && uv run main.py --transport streamable-http --tools chat contacts calendar --tool-tier extended'

# Host port mapped to container 8069 in ./docker-compose.yml
# ponytail: grep the "host:8069" mapping instead of parsing YAML; pass a port explicitly if a compose file gets exotic
_odoo_port() {
    local f
    for f in docker-compose.yml docker-compose.yaml; do
        [ -f "$f" ] && break
    done
    [ -f "$f" ] || { echo "no docker-compose.yml here" >&2; return 1; }
    local port=$(grep -oE '[0-9]+:8069' "$f" | head -1 | cut -d: -f1)
    [ -n "$port" ] || { echo "no port mapped to 8069 in $f" >&2; return 1; }
    echo "$port"
}

# Expose local port via pinggy.io tunnel
# Usage: pinggy        # read port from ./docker-compose.yml
#        pinggy 9000   # explicit port
pinggy() {
    local port=${1:-$(_odoo_port)}
    [ -n "$port" ] || return 1
    echo "pinggy -> localhost:$port"
    ssh -p 443 -R0:localhost:$port free.pinggy.io
}

# ngrok the current Odoo project's port
# Usage: ongrok        # read port from ./docker-compose.yml
#        ongrok 9000   # explicit port
ongrok() {
    local port=${1:-$(_odoo_port)}
    [ -n "$port" ] || return 1
    echo "ngrok http $port"
    ngrok http "$port"
}
