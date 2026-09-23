# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal dotfiles for macOS and Linux (Ubuntu/Debian, Fedora, Alpine): Neovim, zsh/Oh My Zsh, tmux, shell aliases and a few helper scripts, all deployed by `install.sh`. There is no build, lint or test suite.

## Commands

```sh
./install.sh --sync    # copy repo config into place (aliases, scripts, tmux.conf, nvim) — no packages, no clones
./install.sh --local   # full install from this checkout instead of cloning GitHub
./install.sh           # full install; clones github.com/jcapona/dotfiles into a temp dir first
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
- Remote-session plumbing spans files: OSC 52 clipboard forwarding lives in `nvim/lua/config/set.lua` plus tmux `set-clipboard`, and relies on tmux `allow-passthrough`. The matching SSH pane tint (OSC 11) in `shell_aliases` is commented out — `window-style` now paints pane backgrounds, so the escape never reaches the screen inside tmux.
- `config.lua` is a legacy LunarVim config; nothing in `install.sh` deploys it.
- `README.md` is the only user-facing doc. Update it **in the same commit** whenever the observable surface changes: a new or changed `install.sh` flag, a dependency or plugin added or dropped, a destination path moving, or a keybinding changing in nvim or tmux. If a user of these dotfiles could notice the change without reading the diff, it belongs in the README.

## Commit style

Subject prefixed with the area touched (`tmux:`, `install:`, `aliases:`, `zsh-install:`), imperative, explaining the why in the body.

## Trap doors

Things that have already cost a debugging round here. Each one fails silently.

### tmux styles and formats

- `#[none]` clears attributes but **keeps the preceding `#[fg=]`**. In the rounded-pill status format the cap is drawn with `#[fg=<bar bg>,reverse]`, so any text colour set *before* the cap is dead and the text inherits the cap's. Set the text colour **after** `#[none]`. This shipped twice; it reads as correct in the source.
- `bg=default` means the **terminal's** default background, not the bar's. With `window-style` set, anything still saying `default` is the one surface leaking the emulator's colour through.
- `set -gF` resolves `#{@var}` at parse time. Correct for *style* options (`status-style`, `window-style`, `*-border-style`). Wrong for *format* options (`window-status-format`, `status-right`) — `-F` expands `#I`, `#W` and `%H` too, freezing the window name and the clock at load.
- Plugin options must be set **before** `run tpm`. Plugins read them with `show-option` as they load; set afterwards they are silently ignored and you get defaults. A renamed plugin option fails the same silent way.

### What tmux can and cannot own

- `window-style` / `window-active-style` make tmux paint the pane backgrounds. Without them the background belongs to the terminal emulator's profile — GUI state on macOS that cannot live in this repo. No tmux theme plugin sets them; keep them across any theme change and match the colour to the theme's background.
- tmux **cannot** remap the 16 ANSI colours. A program asking for colour 4 gets the emulator's. `LS_COLORS` here is written in indices, so directory and symlink colours are the terminal's, not this repo's. Changing that means truecolor `LS_COLORS`, or OSC 4 from `shell_aliases`.

### Verifying a colour change

- Verify by **rendering**, not by reading the config: attach a throwaway server in a pty and parse the painted escape sequences. Both status-line bugs above read as correct in the source and were only visible in the output.
- "Every colour changed" proves nothing. Two dark themes can differ by under 8 ΔE across the areas that cover the most space, which is invisible. Measure perceptual distance against the colour being replaced, and check contrast on the *rendered* fg/bg pairs.
- This tmux build ignores `TMUX_TMPDIR` (socket dir is hardcoded), so setting it does **not** isolate a test server from the running one. Use `tmux -L <name>` instead, or a test will silently reconfigure the live session.
- `zsh -c 'source f; la'` will not expand aliases — the whole string is parsed before `source` runs. Alias behaviour has to be tested from a script file.

### install.sh

- `SCRIPT_DIR` comes from `BASH_SOURCE`, so a copy of the script run from elsewhere treats *that* directory as the repo and fails or copies the wrong files. Run variants from the repo root.
- `zsh-install.sh` writes `~/.zshrc` with a plain `>` and no backup, so a full install **destroys local edits to it**. There is one in the wild: the live `~/.zshrc` sets `ZSH_THEME="cobalt-spark/cobalt-spark"` on the line after the generated `spaceship` one, which `install.sh` does not know about. A full install silently reverts the prompt.
- `cp` preserves the source file's mode; `scripts/` is installed with `install -m 755` for that reason. `sync-pi` is `644` in the repo and previously landed non-executable.
- `nvim/lazy-lock.json` is gitignored and machine-local. `sync_nvim_config` preserves the local copy and drops any stray one from the source tree — do not "fix" that by copying it.
