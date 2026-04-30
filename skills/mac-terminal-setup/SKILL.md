---
name: mac-terminal-setup
description: Set up a macOS terminal environment with Ghostty as a Warp replacement, Starship prompt, Atuin searchable history, Zinit-managed zsh plugins, mise activation, and the matching config files. Use when Codex needs to configure or reproduce this user's Mac terminal setup, migrate another Mac away from Warp, install Ghostty terminal tooling, or apply the bundled terminal dotfiles safely.
---

# Mac Terminal Setup

## Overview

Use this skill to reproduce the user's preferred macOS terminal setup on a new Mac. The setup installs Ghostty, Starship, Atuin, Zinit, and mise, then applies the bundled Ghostty, Starship, mise, and zsh managed-block configuration.

## Quick Start

Run the bundled installer:

```bash
/Users/ijeongjae/.codex/skills/mac-terminal-setup/scripts/setup-mac-terminal.zsh
```

For a dry run:

```bash
/Users/ijeongjae/.codex/skills/mac-terminal-setup/scripts/setup-mac-terminal.zsh --dry-run
```

For validation against a temporary home directory without Homebrew installs:

```bash
tmp_home="$(mktemp -d)"
/Users/ijeongjae/.codex/skills/mac-terminal-setup/scripts/setup-mac-terminal.zsh --skip-brew --home "$tmp_home"
```

## Workflow

1. Confirm the target is macOS with zsh and Homebrew available.
2. Run `scripts/setup-mac-terminal.zsh`.
3. If Homebrew is missing, stop and ask the user to install Homebrew first; do not install Homebrew automatically.
4. After setup, tell the user to open a new Ghostty tab or run `exec zsh`.

## What The Installer Changes

- Installs Homebrew packages: `starship`, `atuin`, `zinit`, `mise`.
- Installs Homebrew cask: `ghostty`.
- Creates `~/.hushlogin` to suppress macOS `Last login` text before the prompt.
- Writes `~/.config/ghostty/config` from `assets/ghostty-config`.
- Writes `~/.config/starship.toml` from `assets/starship.toml`.
- Writes `~/.config/mise/config.toml` from `assets/mise-config.toml`.
- Inserts or replaces only the managed block between `# >>> mac-terminal-setup >>>` and `# <<< mac-terminal-setup <<<` in `~/.zshrc`.

Existing config files are backed up with `.bak.YYYYMMDD-HHMMSS` before they are changed. The installer never copies private shell exports, tokens, project-specific variables, project `.mise.toml`, or `.tool-versions` files.

## Included Shell Behavior

- `mise activate zsh` is enabled in the managed zsh block.
- Zinit loads `zsh-users/zsh-completions`, `zsh-users/zsh-autosuggestions`, `zdharma-continuum/fast-syntax-highlighting`, and `olets/zsh-transient-prompt`.
- Atuin enables searchable shell history via `atuin init zsh`.
- Starship renders the Warp-like prompt from `assets/starship.toml`.
- Transient prompt keeps the active prompt rich but collapses previous prompts to a short `%`.

## Validation

After running the installer, verify:

```bash
zsh -n ~/.zshrc
brew list --formula | rg '^(atuin|starship|zinit|mise)$'
brew list --cask | rg '^ghostty$'
test -f ~/.config/ghostty/config
test -f ~/.config/starship.toml
test -f ~/.config/mise/config.toml
test -f ~/.hushlogin
```

Do not use `mise --version` as a hard failure in Codex desktop contexts; it can panic in some sandboxed environments. Prefer `command -v mise` plus Homebrew package checks.
