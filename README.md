dotfiles
========

This repository contains my `$HOME` configuration files. For these top-level
“dot”-files, simply create a symbolic link from this directory to your `$HOME`:

```
ln -s `find $(pwd) -maxdepth 1 -not -type d -name "\.*" -not -name "\.gitignore"`
```


X11 Keymap
----------

- Create a symbolic link for `evdev` pointing to
  `/usr/share/X11/xkb/keycodes/evdev`
- Create a symbolic link for `symbols/us` pointing to
  `/usr/share/X11/xkb/symbols/us`


ALSA
----

- Create a symbolic link for `config` pointing to
  `$HOME/.config/ladspa_dsp/config`


Autostart
---------

- Create a symbolic link for `tmux.desktop` pointing to
  `$HOME/.config/autostart/tmux.desktop`


Systemd
-------

- Create a symbolic link for `emacs.service` pointing to
  `/lib/systemd/system/emacs.service`
