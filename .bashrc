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
