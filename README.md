dotfiles
========

Personal configuration files for a terminal-focused development environment on Linux: dark theming, keyboard-driven workflow optimizations, and persistent session management.


Contents
--------

| File/Directory | Application | Description |
|----------------|-------------|-------------|
| `.bashrc` | Bash | Thin loader that sources modular configs from `bashrc.d/` |
| `bashrc.d/` | Bash | Modular shell config: history, prompt, aliases, git, Claude, PATH |
| `.tmux.conf` | Tmux | Terminal multiplexer with session persistence |
| `tmux-resurrect-fix-pane-cwd.sh` | Tmux | Post-save hook that corrects pane directories in resurrect saves |
| `.emacs`, `.emacs.d/` | Emacs | Text editor with daemon support |
| `alacritty.toml` | Alacritty | GPU-accelerated terminal emulator |
| `keyd/` | keyd | System-wide keyboard remapping |
| `ssh/` | OpenSSH | SSH client configuration |
| `Autostart/` | Desktop | XDG autostart entries |


Theming
-------

Dark theme across all applications:

- **Font**: Maple Mono NF, size 22.5 (22 leaves an empty line before the tmux status line)
- **Alacritty**: Catppuccin Macchiato, no window decorations, maximized on startup
- **Tmux**: Catppuccin Macchiato rounded-pill status bar
- **Emacs**: Miasma theme (loaded from the `.emacs.d/themes` submodule)


Bash Configuration
------------------

Modular configs live in `bashrc.d/`, sourced alphabetically by `.bashrc`. Key aliases:

**Editor:**
- `e <file>` - Open file in emacsclient (terminal)
- `es <file>` - `sudo -e`; edits as root through `SUDO_EDITOR='emacsclient -t'`

**Git:**
- `gs` - git status
- `gd` - git diff
- `gl` - git log
- `gpo` - git push origin (current branch)
- `gfo` - git fetch origin (current branch)
- `glp` - Files changed in the last push (last commit on `origin/<branch>`)
- `gcam` - git commit -am
- `gec` - Empty commit to trigger a build
- `grba` - git rebase --autostash

**Docker:**
- `dcu` - docker compose down && docker compose up
- `dcd` - docker compose down
- `dcl` - docker compose ls

**Claude:**
- `cl` - claude (mode comes from `settings.json` defaultMode)
- `clr` - claude --resume
- `clu` - claude update
- `jcheck` - jCodemunch MCP config health check
- `cl-mcp-odoo <name> <url> <db> <user> <password>` - Register an Odoo MCP server

**Other:**
- `s` - sudo
- `xc` - wl-copy
- `rgo` - ripgrep for Odoo (excludes `*.po`)
- `getip <host>` - Resolve hostname to IP and copy it to the clipboard
- `ongrok [port]` - ngrok the current Odoo project's port (read from `docker-compose.yml` when omitted)
- `pinggy <port>` - Expose a local port via a pinggy.io tunnel


Tmux Configuration
------------------

**Prefix key**: `Ctrl+z` (instead of default `Ctrl+b`)

**Plugins** (managed via tpm):
- tmux-sensible - Sensible defaults
- tmux-prefix-highlight - Status-bar indicator while the prefix is held
- tmux-resurrect - Save/restore sessions, pane contents included
- tmux-continuum - Auto-save at the default 15-minute interval, restore and boot on

**Key bindings:**
- `Prefix + c` - Show clock
- `Prefix + t` - New window (swapped from defaults)
- `Prefix + M` - Move the current window to a prompted index, shifting occupants
- Windows and panes start at index 1, not 0
- Automatic window renumbering on close
- Mouse mode on: the scroll wheel enters copy-mode instead of replaying shell history

**Pane cwd fix:**

`tmux-resurrect-fix-pane-cwd.sh` runs as the `@resurrect-hook-post-save-layout` hook. It rewrites each saved pane's directory from `/proc/<pane_pid>/cwd` (`#{pane_current_path}` follows the foreground process, not the shell) and repairs the field shift resurrect produces when a pane title is empty. To revert, drop the `@resurrect-hook-post-save-layout` line from `.tmux.conf`.


keyd Keyboard Remapping
-----------------------

System-wide keyboard remapping via keyd daemon.

**Tmux window switching** (either Alt key, held):
- `Alt+1` through `Alt+9` - Switch to tmux window 1-9
- `Alt+s` - Open tmux session switcher

**Typographic characters** (Meta/Compose key layer):
- `` ` `` - Left single quote (‘)
- `'` - Right single quote (’)
- `Shift + [` - Left double quote (“)
- `Shift + ]` - Right double quote (”)
- `-` - En-dash (–)
- `Shift+-` - Em-dash (—)
- `n` - ñ, `e` - é, `i` - í

**Esperanto characters** (same layer, `Shift` for uppercase):
- `c` - ĉ, `g` - ĝ, `h` - ĥ, `j` - ĵ, `s` - ŝ, `u` - ŭ


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

The `[cursor]` smooth-motion keys require the alacritty-smooth-cursor fork. Upstream Alacritty ignores them.

**SSH:**

```bash
ln -sf $(pwd)/ssh/config ~/.ssh/config
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

**Autostart (PulseAudio Volume Control):**

```bash
ln -s $(pwd)/Autostart/pavucontrol.desktop ~/.config/autostart/pavucontrol.desktop
```

**Emacs daemon:**

Uses the unit Emacs ships at `/usr/lib/systemd/user/emacs.service`; no unit file lives in this repo.

```bash
systemctl --user enable --now emacs
```


Emacs Setup
-----------

Emacs runs as a daemon via systemd for instant startup.

**Usage:**
- `emacsclient -t <file>` - Open in terminal (aliased to `e`)
- `sudo -e <file>` - Edit as root in a terminal frame (aliased to `es`)

**Packages** (MELPA, installed on first run by `use-package`):
- ws-butler - Strip trailing whitespace, but only on lines actually edited
- markdown-mode - With `auto-fill-mode`
- corfu + corfu-terminal - In-buffer completion popup; the terminal variant because corfu's child-frame popup is GUI-only
- cape, orderless - Completion backends and matching style
- sudo-edit - Edit files with elevated privileges

**Configuration:**
- Line numbers enabled globally
- Menu bar disabled
- Auto-fill in text and Markdown buffers
- Python mode: spaces, not tabs (PEP 8)
- `find-file-visit-truename` on, so symlinked files survive a tmux-resurrect restore

**Agilis project completion:**

`.emacs.d/manual-packages/agilis-projects/` adds Odoo completion to Markdown buffers. On a line starting `Project: `, it completes active `project.project` names; picking one scaffolds a `  * Task: ` or `  * Ticket: ` line below, depending on whether the project has a helpdesk team. That line then completes the project's task or ticket names.

Names come from `agilis-projects.py` over XML-RPC. Credentials are read via `auth-source` for host `agilis.odoo.com`, which needs `login`, `password`, `database`, and `url` fields. `M-x agilis-projects-refresh` clears the session cache; `C-c t` inserts a Task/Ticket line under the nearest preceding `Project: `.


Tmux Plugins
------------

Install plugins after cloning:

```bash
# Clone TPM if not present
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux and press Prefix + I to install plugins
```
