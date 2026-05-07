#!/bin/zsh
set -euo pipefail

BEGIN_MARKER="# >>> mac-terminal-setup >>>"
END_MARKER="# <<< mac-terminal-setup <<<"
DRY_RUN=0
SKIP_BREW=0
TARGET_HOME="$HOME"

usage() {
  cat <<'USAGE'
Usage: setup-mac-terminal.zsh [--dry-run] [--skip-brew] [--home PATH]

Sets up Ghostty, Starship, Atuin, Zinit, mise, and the managed zsh block.

Options:
  --dry-run     Print actions without writing files or installing packages.
  --skip-brew   Skip Homebrew package installation checks.
  --home PATH   Apply dotfiles to PATH instead of $HOME.
USAGE
}

while (( $# > 0 )); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --skip-brew)
      SKIP_BREW=1
      shift
      ;;
    --home)
      if (( $# < 2 )); then
        print -u2 -- "Missing value for --home"
        exit 2
      fi
      TARGET_HOME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      print -u2 -- "Unknown option: $1"
      usage
      exit 2
      ;;
  esac
done

SCRIPT_DIR="${0:A:h}"
SKILL_DIR="${SCRIPT_DIR:h}"
ASSET_DIR="$SKILL_DIR/assets"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

log() {
  print -r -- "[mac-terminal-setup] $*"
}

run_cmd() {
  print -r -- "+ $*"
  if (( ! DRY_RUN )); then
    "$@"
  fi
}

require_asset() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    print -u2 -- "Missing asset: $path"
    exit 1
  fi
}

ensure_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    print -u2 -- "This installer supports macOS only."
    exit 1
  fi
}

ensure_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    print -u2 -- "Homebrew is required but was not found."
    print -u2 -- "Install it first from https://brew.sh, then rerun this script."
    exit 1
  fi
}

install_formula() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    log "formula already installed: $formula"
  else
    run_cmd brew install "$formula"
  fi
}

install_cask() {
  local cask="$1"
  if brew list --cask "$cask" >/dev/null 2>&1; then
    log "cask already installed: $cask"
  else
    run_cmd brew install --cask "$cask"
  fi
}

backup_file() {
  local target="$1"
  if [[ -e "$target" ]]; then
    run_cmd cp "$target" "$target.bak.$TIMESTAMP"
  fi
}

install_asset() {
  local source="$1"
  local target="$2"
  require_asset "$source"

  if [[ -f "$target" ]] && cmp -s "$source" "$target"; then
    log "unchanged: $target"
    return
  fi

  run_cmd mkdir -p "${target:h}"
  backup_file "$target"
  run_cmd cp "$source" "$target"
  log "installed: $target"
}

install_hushlogin() {
  local target="$TARGET_HOME/.hushlogin"
  if [[ -e "$target" ]]; then
    log "unchanged: $target"
    return
  fi

  run_cmd mkdir -p "$TARGET_HOME"
  run_cmd touch "$target"
  log "installed: $target"
}

apply_zshrc_block() {
  local block_source="$ASSET_DIR/zshrc-managed-block.zsh"
  local zshrc="$TARGET_HOME/.zshrc"
  local input_file="$zshrc"
  local existed=0
  local tmp
  require_asset "$block_source"

  if (( DRY_RUN )); then
    log "would update managed block in: $zshrc"
    return
  fi

  mkdir -p "$TARGET_HOME"
  if [[ -f "$zshrc" ]]; then
    existed=1
  else
    input_file="/dev/null"
  fi

  local has_begin=0
  local has_end=0
  if (( existed )); then
    grep -Fqx "$BEGIN_MARKER" "$zshrc" && has_begin=1 || true
    grep -Fqx "$END_MARKER" "$zshrc" && has_end=1 || true
  fi

  if (( has_begin != has_end )); then
    print -u2 -- "Found only one mac-terminal-setup marker in $zshrc. Fix the markers manually before rerunning."
    exit 1
  fi

  tmp="$(mktemp)"
  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" -v block_file="$block_source" '
    BEGIN {
      while ((getline line < block_file) > 0) {
        block = block line "\n"
      }
      close(block_file)
      replacement = begin "\n" block end "\n"
      inserted = 0
      skipping = 0
    }
    $0 == begin {
      printf "%s", replacement
      skipping = 1
      inserted = 1
      next
    }
    $0 == end && skipping {
      skipping = 0
      next
    }
    !skipping {
      print
    }
    END {
      if (!inserted) {
        if (NR > 0) {
          print ""
        }
        printf "%s", replacement
      }
    }
  ' "$input_file" > "$tmp"

  if (( existed )) && cmp -s "$tmp" "$zshrc"; then
    rm -f "$tmp"
    log "unchanged: $zshrc"
  else
    if (( existed )); then
      backup_file "$zshrc"
    fi
    mv "$tmp" "$zshrc"
    log "installed managed block: $zshrc"
  fi
}

validate_setup() {
  local zshrc="$TARGET_HOME/.zshrc"

  if (( DRY_RUN )); then
    log "would validate generated files and Homebrew packages"
    return
  fi

  if [[ -f "$zshrc" ]]; then
    run_cmd zsh -n "$zshrc"
  fi

  if (( ! SKIP_BREW )); then
    brew list --formula atuin git-delta starship zinit mise >/dev/null
    brew list --cask ghostty >/dev/null
  fi

  [[ -f "$TARGET_HOME/.config/ghostty/config" ]]
  [[ -f "$TARGET_HOME/.config/starship.toml" ]]
  [[ -f "$TARGET_HOME/.config/mise/config.toml" ]]
  [[ -f "$TARGET_HOME/.hushlogin" ]]

  log "validation passed"
}

main() {
  require_asset "$ASSET_DIR/ghostty-config"
  require_asset "$ASSET_DIR/starship.toml"
  require_asset "$ASSET_DIR/mise-config.toml"
  require_asset "$ASSET_DIR/zshrc-managed-block.zsh"

  ensure_macos

  if (( ! SKIP_BREW )); then
    ensure_brew
    install_cask ghostty
    install_formula atuin
    install_formula git-delta
    install_formula starship
    install_formula zinit
    install_formula mise
  else
    log "skipping Homebrew package checks"
  fi

  install_hushlogin
  install_asset "$ASSET_DIR/ghostty-config" "$TARGET_HOME/.config/ghostty/config"
  install_asset "$ASSET_DIR/starship.toml" "$TARGET_HOME/.config/starship.toml"
  install_asset "$ASSET_DIR/mise-config.toml" "$TARGET_HOME/.config/mise/config.toml"
  apply_zshrc_block
  validate_setup

  log "done. Open a new Ghostty tab or run: exec zsh"
}

main "$@"
