Developer Environment Checklist (for Ubuntu)
============================================

The following are sequences on how I setup my general (with Python (Odoo))
development environment inside Ubuntu:

1. Install `tmux`.
2. Install `zsh`.
3. Install `emacs`.
   - (Modify `.emacs` (and `.emacs.d`) accordingly.)
   - (Check if `elpy-pyenv` setup is relevant; if yes, check `brave` bookmarks.)
   - (If dev env is for `Python`, install `pylint` and `pep8`, then `ln -s`
   `.pylintrc` from `dotfiles` to `home` directory.)
4. Run `git clone git@github.com:zhaqenl/dotfiles.git`
5. Create respective symbolic links of files inside `dotfiles` directory.
6. Run `gnome-tweak-tools` then swap behavior of `caps` and `esc` keys.
7. Run `unity-tweak-tool` then hide desktop from `Alt-tab` key combination.
8. Install `brave` browser then get data file/directory from Google Drive.
9. Install `odoo`
   - Check the following
     [link](https://www.odoo.com/forum/help-1/question/v8-solved-why-does-the-connection-to-the-database-fail-with-ubuntu-14-04-75664)
     to address peer authentication error.
   - Attempt to install `odoo-profiler`
     + To make `odoo` detect `pstats_print2list` installation, run `sudo -i`
       first.
