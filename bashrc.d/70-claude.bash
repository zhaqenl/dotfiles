# Claude CLI shortcuts and tools
alias cl="claude"                                  # mode comes from settings.json defaultMode
alias clr="claude --resume"
alias clu="claude update"                          # update Claude Code
alias cl-pulse-update='cd ~/claude-pulse && python claude_status.py --update; cd -'

# jCodemunch MCP config health. Same invocation as the settings.json hooks, so the
# checker is the code that actually runs, with no version skew.
# Two warnings are expected and never actionable: the whole "CLAUDE.md check"
# sub-section, and "no AI provider configured — signature fallback will be used".
alias jcheck='uvx --from git+https://github.com/jgravelle/jcodemunch-mcp.git jcodemunch-mcp config --check'

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
