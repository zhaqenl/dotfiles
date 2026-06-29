# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source all modular config files from bashrc.d
for f in ~/.bashrc.d/*.bash; do
    [ -r "$f" ] && . "$f"
done
unset f
. "$HOME/.cargo/env"

# pnpm
export PNPM_HOME="/home/lenovo/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/lenovo/google-cloud-sdk/path.bash.inc' ]; then . '/home/lenovo/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/lenovo/google-cloud-sdk/completion.bash.inc' ]; then . '/home/lenovo/google-cloud-sdk/completion.bash.inc'; fi
