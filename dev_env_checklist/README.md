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
6. Setup `redshift`.
7. Setup `RiseUp`.
8. Setup `[dnscrypt](https://sorenpoulsen.com/install-dnscrypt-proxy-2-on-ubuntu-1604)`.
9. Run `gnome-tweak-tools` then swap behavior of `caps` and `esc` keys.
10. Run `unity-tweak-tool` then hide desktop from `Alt-tab` key combination.
11. Install `brave` browser then restore brave settings via config file from
    Mega or from Phone’s Local Storage.
12. Install `odoo` through
    [this link](https://www.rosehosting.com/blog/install-multiple-odoo-instances-on-a-single-machine/)
