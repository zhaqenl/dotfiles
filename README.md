dotfiles
========

Personal configuration files for a terminal-focused development environment on Linux. Features consistent theming across applications, keyboard-driven workflow optimizations, and persistent session management.


Contents
--------

| File/Directory | Application | Description |
|----------------|-------------|-------------|
| `.bashrc` | Bash | Thin loader that sources modular configs from `bashrc.d/` |
| `bashrc.d/` | Bash | Modular shell config: history, prompt, aliases, git, Claude, PATH |
| `.tmux.conf` | Tmux | Terminal multiplexer with session persistence |
| `.emacs`, `.emacs.d/` | Emacs | Text editor with daemon support |
| `alacritty.toml` | Alacritty | GPU-accelerated terminal emulator |
| `keyd/` | keyd | System-wide keyboard remapping |
| `Autostart/` | Desktop | XDG autostart entries |


Theming
-------

Consistent dark theme across all applications:

- **Color scheme**: Miasma (dark background with warm earth tones)
- **Font**: JetBrainsMono Nerd Font, size 22
- **Alacritty**: Miasma colors, no window decorations
- **Emacs**: Miasma theme
- **Tmux**: Gruvbox dark theme


Bash Configuration
------------------

Modular configs live in `bashrc.d/`, sourced alphabetically by `.bashrc`. Key aliases:

**Editor:**
- `e <file>` - Open file in emacsclient (terminal)
- `es <file>` - Open file in emacsclient (GUI frame)

**Git:**
- `gs` - git status
- `gd` - git diff
- `gpo` - git push origin (current branch)
- `gfo` - git fetch origin (current branch)
- `glp` - git log with patch
- `gcam` - git commit -am
- `grba` - git rebase --abort

**Docker:**
- `dcu` - docker compose up -d
- `dcd` - docker compose down

**Other:**
- `s` - sudo
- `cl` - claude (Claude CLI)
- `clr` - claude --resume
- `xc` - xclip -selection clipboard


Tmux Configuration
------------------

**Prefix key**: `Ctrl+z` (instead of default `Ctrl+b`)

**Plugins** (managed via tpm):
- tmux-sensible - Sensible defaults
- tmux-gruvbox - Dark theme
- tmux-resurrect - Save/restore sessions
- tmux-continuum - Auto-save sessions every 1 minute

**Key bindings:**
- `Prefix + c` - Show clock
- `Prefix + t` - New window (swapped from defaults)
- Windows and panes start at index 1, not 0
- Automatic window renumbering on close


keyd Keyboard Remapping
-----------------------

System-wide keyboard remapping via keyd daemon.

**Tmux window switching** (Right Alt layer):
- `Alt+1` through `Alt+8` - Switch to tmux window 1-8
- `Alt+s` - Open tmux session switcher

**Typographic characters** (Meta/Compose key layer):
- `` ` `` - Left single quote (‘)
- `'` - Right single quote (’)
- `Shift + [` - Left double quote (“)
- `Shift + ]` - Right double quote (”)
- `-` - En-dash (–)
- `Shift+-` - Em-dash (—)
- `n` - ñ


Installation
------------

**Home directory dotfiles:**

Create symbolic links for top-level dotfiles and the `bashrc.d/` directory:

```bash
ln -s `find $(pwd) -maxdepth 1 -not -type d -name "\.*" -not -name "\.gitignore"` ~
ln -s $(pwd)/bashrc.d ~/.bashrc.d
```

**Alacritty:**

```bash
ln -s $(pwd)/alacritty.toml ~/.config/alacritty/alacritty.toml
```

**keyd:**

```bash
sudo ln -s $(pwd)/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable keyd
sudo systemctl start keyd
```

**Autostart (Alacritty with Tmux):**

```bash
ln -s $(pwd)/Autostart/alacritty.desktop ~/.config/autostart/alacritty.desktop
```

**Systemd (Emacs daemon):**

```bash
sudo ln -s $(pwd)/systemd/emacs.service /lib/systemd/system/emacs.service
sudo systemctl enable emacs
sudo systemctl start emacs
```


Emacs Setup
-----------

Emacs runs as a daemon via systemd for instant startup.

**Usage:**
- `emacsclient -t <file>` - Open in terminal (aliased to `e`)
- `emacsclient -c <file>` - Open in GUI frame (aliased to `es`)

**Packages:**
- sudo-edit - Edit files with elevated privileges

**Configuration:**
- Line numbers enabled globally
- Menu bar disabled
- Python mode: PEP 8 compliant (spaces, whitespace cleanup on save)
- XML mode: Whitespace cleanup on save


Tmux Plugins
------------

Install plugins after cloning:

```bash
# Clone TPM if not present
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux and press Prefix + I to install plugins
```
