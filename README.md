# Personal environment setup

Dotfiles and install script for setting up a development environment on macOS and Linux (Ubuntu/Debian, Fedora, Alpine).

## Install

```
curl -fsSL https://raw.githubusercontent.com/jcapona/dotfiles/master/install.sh | bash
```

or

```
wget -O - https://raw.githubusercontent.com/jcapona/dotfiles/master/install.sh | bash
```

### From a local clone

To install from a checked-out copy of this repo instead of cloning from GitHub:

```
./install.sh --local
```

### Syncing config changes

After editing a config file here, push it into place without reinstalling
anything:

```
./install.sh --sync
```

This copies `shell_aliases`, `tmux.conf`, `nvim/` and `scripts/` to their
destinations and stops — no packages, no plugin clones, no `~/.zshrc`
regeneration. It reloads running tmux sessions itself; nvim needs a restart.
Implies `--local`, so it always syncs from this checkout.

## What gets installed

- **Neovim** — via Homebrew (macOS) or package manager (Linux)
- **Zsh + Oh My Zsh** — with spaceship prompt, autosuggestions, syntax highlighting, fzf, zsh-z, and more
- **tmux** — with TPM plugin manager and a hand-rolled Gruvbox status line
- **NVM** — Node.js version manager (latest)
- **Nerd Font** — DroidSansMono for terminal icons
- **Shell aliases** — git shortcuts, systemd helpers, utility functions
- **Custom scripts** — `mssh`, `sync-dir`, `sync-pi`, `new-pi`, `transfer-sh` (installed to `~/.local/bin`)

## Neovim

**Leader key:** `<Space>`

### Navigation

| Key | Action |
|-----|--------|
| `<Space>ff` | Find files (Telescope) |
| `<C-p>` | Find git files |
| `<Space>fs` | Live grep |
| `<Space>fg` | Grep with input |
| `<Space><Tab>` | List buffers |
| `<Space>fh` | Help tags |
| `<Space>e` | Toggle file explorer (Neo-tree) |

### Editing

| Key | Action |
|-----|--------|
| `<Space>p` | Paste without losing clipboard (visual) |
| `<Space>f` | Format buffer |
| `<C-s>` | Replace word under cursor / visual selection |
| `K` / `J` | Move visual block up / down |
| `<Space>u` | Toggle undo tree |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `go` | Go to type definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `gs` | Signature help |
| `<F2>` | Rename symbol |
| `<F3>` | Format (async) |
| `<F4>` | Code actions |
| `<C-Space>` | Trigger completion |

### Buffers

| Key | Action |
|-----|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<S-w>` | Close buffer |

### Git

| Key | Action |
|-----|--------|
| `<Space>gb` | Blame current line (gitsigns) |

### Multicursor

| Key | Action |
|-----|--------|
| `<Space>n` / `<Space>N` | Add cursor at next / previous match |
| `<Space>s` / `<Space>S` | Skip next / previous match |
| `<Space>A` | Add cursors to all matches |
| `<Space>x` | Delete current cursor |
| `<Esc>` | Toggle / clear multicursors |

### Plugins

lsp-zero, nvim-cmp, Mason, Treesitter, Telescope, Neo-tree, barbar, lualine, gitsigns, multicursor, undotree, todo-comments, alpha (dashboard), tokyonight theme

### LSP servers

Configured via Mason: **pyright** (Python)

## tmux

**Prefix:** `C-b` (default) + `C-a` (secondary)

| Key | Action |
|-----|--------|
| `"` | Split pane horizontally (current path) |
| `%` | Split pane vertically (current path) |
| `v` | Begin selection (copy mode, vi-style) |
| `C-v` | Toggle rectangle selection (copy mode) |
| `y` | Copy selection to clipboard (copy mode) |
| `prefix + F12` | Open tmux-menus popup |
| `F12` (no prefix) | Toggle the prefix off/on — lets keys fall through to a nested/remote tmux. Only bound on the local machine (skipped when `$SSH_TTY` is set) |
| `prefix + p` / `prefix + o` | Previous window / next pane (tmux builtins, explicitly reclaimed from tmux-agent-status) |
| `prefix + S` | Agent switcher popup |
| `prefix + O` | Toggle agent sidebar |
| `prefix + N` | Jump to next finished agent |
| `prefix + W` | Put session in wait mode |
| `prefix + P` | Park session for later |

Pane navigation via **tmux-pain-control** (`prefix + h/j/k/l`).

### Plugins

tpm, tmux-sensible, tmux-yank, tmux-resurrect, tmux-continuum (auto-restore), tmux-pain-control, tmux-menus, treemux, tmux-agent-status

## Shell aliases

### Git
`ga` (add), `gap` (add -p), `gc` (commit -v), `gco` (checkout), `gcr` (clone --recursive), `gd` (diff), `gg` (grep), `gst` (status)

### Systemd
`sstatus`, `sstart`, `sstop`, `srestart`, `senable`, `sdisable`

### Misc
`ll` (ls -lah), `la` (ls -a), `bbat` (bat plain), `pbcopy`/`pbpaste` (xclip wrappers), `docker-stop-rm`, `lso` (ls with octal permissions)
