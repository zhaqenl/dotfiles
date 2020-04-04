Developer Environment Checklist (for Ubuntu)
============================================

The following are sequences on how I setup my general (with Python (Odoo))
development environment inside Ubuntu:

1. Install `tmux`.
2. Install `zsh`.
3. Install `emacs`.
   - (Check if `elpy-pyenv` setup is relevant; if yes, check `brave` bookmarks.)
   - (If dev env is for `Python`, install `pylint` and `pep8`, then `ln -s`
   `.pylintrc` from `dotfiles` to `home` directory.)
4. Run `git clone https://github.com/zhaqenl/dotfiles.git`
5. Create respective symbolic links of files inside `dotfiles` directory.
6. Run `gnome-tweak-tools` then swap behavior of `caps` and `esc` keys.
7. Run `unity-tweak-tool` then hide desktop from `Alt-tab` key combination.
8. Install `brave` browser then restore brave settings via config file from
   Mega or from Phone’s Local Storage.
9. Install `odoo` through
   [this link](https://www.rosehosting.com/blog/install-multiple-odoo-instances-on-a-single-machine/)
