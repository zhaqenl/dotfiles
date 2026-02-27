# Claude CLI shortcuts and tools

alias cl="claude"
alias clr="claude --resume"
alias cldr="claude --resume --dangerously-skip-permissions"  # resume + skip permissions
alias cld="claude --dangerously-skip-permissions"  # skip permission prompts
alias clu="claude update"                          # update Claude Code
alias cl-pulse-update='cd ~/claude-pulse && python claude_status.py --update; cd -'

# Register an Odoo MCP server with Claude Code
cl-mcp-odoo() {
    if [ $# -ne 5 ]; then
        echo "Usage: cl-mcp-odoo <mcp-name> <url> <db> <user> <password>"
        return 1
    fi

    claude mcp add --transport stdio \
      --env ODOO_URL="$2" \
      --env ODOO_DB="$3" \
      --env ODOO_USER="$4" \
      --env ODOO_PASSWORD="$5" \
      --env ODOO_YOLO=true \
      --scope local \
      "$1" -- uvx mcp-server-odoo
}
