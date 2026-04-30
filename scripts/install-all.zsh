#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
TARGET_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"

usage() {
  cat <<'USAGE'
Usage: install-all.zsh [--target PATH]

Installs every skill under ./skills into Codex's skill discovery path.

Options:
  --target PATH  Target skills root. Defaults to ${CODEX_HOME:-$HOME/.codex}/skills.
USAGE
}

while (( $# > 0 )); do
  case "$1" in
    --target)
      if (( $# < 2 )); then
        print -u2 -- "Missing value for --target"
        exit 2
      fi
      TARGET_ROOT="$2"
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

for skill_dir in "$REPO_ROOT"/skills/*(/N); do
  "$SCRIPT_DIR/install-skill.zsh" "${skill_dir:t}" --target "$TARGET_ROOT"
done
