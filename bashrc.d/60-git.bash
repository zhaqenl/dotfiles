# Git aliases and functions

alias gs='git status'
alias gd='git diff'
alias gcam='git commit -am'
alias gec='git commit --allow-empty -m "Trigger Build"'
alias grba='git rebase --autostash'
alias gl='git log'

# Fetch current branch from origin
gfo() {
    git fetch origin "$(git branch --show-current)"
}

# Push current branch to origin
gpo() {
    git push origin "$(git branch --show-current)"
}

# Show files changed in the last push
glp() {
    local branch=$(git branch --show-current)
    local remote_ref="origin/$branch"

    git log -1 --name-only --format="Commit: %h - %s%nPushed: %ad" --date=format:"%Y-%m-%d %H:%M:%S" "$remote_ref"
}

# SSH agent with zhaqenl GitHub key
alias zhaqenl="eval '$(ssh-agent -s)' && ssh-add ~/.ssh/id_ed25519_zhaqenl_github"

# Auth + push in one step
alias zgpo='zhaqenl && gpo'
