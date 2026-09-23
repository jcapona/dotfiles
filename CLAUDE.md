# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal dotfiles for macOS and Linux (Ubuntu/Debian, Fedora, Alpine): Neovim, zsh/Oh My Zsh, tmux, shell aliases and a few helper scripts, all deployed by `install.sh`. There is no build, lint or test suite.

## Commands

```sh
./install.sh --sync    # copy repo config into place (aliases, scripts, tmux.conf, nvim) — no packages, no clones
./install.sh --local   # full install from this checkout instead of cloning GitHub
./install.sh           # full install; clones github.com/jcapona/dotfiles into a temp dir first
docker build .         # Ubuntu smoke test — runs install.sh WITHOUT --local, so it tests GitHub master, not local edits
```

After editing any config, `./install.sh --sync` is the way to see it live: it reloads running tmux sessions itself; nvim needs a restart.

## How deployment works

Repo files are **copied**, not symlinked, so editing a file here changes nothing until a sync. Where each file lands (all in `install.sh`, `sync_*` functions):

| Repo | Destination |
|------|-------------|
| `shell_aliases` | `~/.shell_aliases` (sourced from `~/.zshrc`) |
| `scripts/*` | `~/.local/bin/` via `install -m 755` (so repo mode doesn't matter) |
| `tmux.conf` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim/` (tree is deleted and replaced; local `lazy-lock.json` is preserved) |

- `~/.zshrc` is **generated**, not stored: `zsh-install.sh` (vendored from deluan/zsh-in-docker) writes it from `zshrc_template`, and `install.sh` then appends the aliases source line and `~/.local/bin` PATH. To change zshrc content, edit the template in `zsh-install.sh`; `--sync` does not regenerate it.
- `--sync` must never touch `~/.local/share/nvim` or `~/.cache/nvim` (that would re-download every Mason server/parser); only the full install's `configure_nvim` wipes them.
- `install.sh` must stay idempotent — re-runs skip existing clones (nvm, TPM, Oh My Zsh plugins/themes). Keep new steps guarded the same way.
- macOS vs Linux branching is on `uname` (`PLATFORM`) in `install.sh`; package installs go through `install_packages`, which picks brew/apt/apk/dnf.

## Layout notes

- **Neovim**: `nvim/init.lua` → `lua/config/{set,remap,lazy}.lua`; lazy.nvim imports every file in `lua/config/plugins/` as a plugin spec, so a new plugin is a new file there.
- **tmux**: plugins via TPM (installed by `install_and_configure_tmux`); status line is hand-rolled in `tmux.conf`, not a theme plugin. `tmux-agent-status` tracks the user's own fork. Several bindings are deliberately guarded (F12 passthrough skipped under `$SSH_TTY`; builtins `p`/`o` reclaimed from agent-status) — read the comments before rebinding.
- Remote-session plumbing spans files: SSH pane tinting (OSC 11) lives in `shell_aliases` and relies on tmux `allow-passthrough`; OSC 52 clipboard forwarding lives in `nvim/lua/config/set.lua` plus tmux `set-clipboard`.
- `config.lua` is a legacy LunarVim config; nothing in `install.sh` deploys it.
- `README.md` documents keybindings and plugins — update it when changing bindings in nvim or tmux.

## Commit style

Subject prefixed with the area touched (`tmux:`, `install:`, `aliases:`, `zsh-install:`), imperative, explaining the why in the body.
