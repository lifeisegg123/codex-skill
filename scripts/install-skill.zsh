#!/bin/zsh
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: install-skill.zsh <skill-name> [--target PATH]

Installs one skill from this repository into Codex's skill discovery path.
The install is a symlink by default so repository updates are reflected immediately.

Options:
  --target PATH  Target skills root. Defaults to ${CODEX_HOME:-$HOME/.codex}/skills.
USAGE
}

if (( $# == 0 )); then
  usage
  exit 2
fi

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
SKILLS_ROOT="$REPO_ROOT/skills"
TARGET_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
SKILL_NAME=""

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
    -*)
      print -u2 -- "Unknown option: $1"
      usage
      exit 2
      ;;
    *)
      if [[ -n "$SKILL_NAME" ]]; then
        print -u2 -- "Only one skill name can be installed at a time"
        exit 2
      fi
      SKILL_NAME="$1"
      shift
      ;;
  esac
done

if [[ -z "$SKILL_NAME" ]]; then
  print -u2 -- "Missing skill name"
  usage
  exit 2
fi

SOURCE="$SKILLS_ROOT/$SKILL_NAME"
TARGET="$TARGET_ROOT/$SKILL_NAME"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "$SOURCE/SKILL.md" ]]; then
  print -u2 -- "Skill not found or missing SKILL.md: $SOURCE"
  exit 1
fi

mkdir -p "$TARGET_ROOT"

if [[ -L "$TARGET" ]]; then
  CURRENT_TARGET="$(readlink "$TARGET")"
  if [[ "$CURRENT_TARGET" == "$SOURCE" ]]; then
    print -r -- "Already installed: $SKILL_NAME -> $SOURCE"
    exit 0
  fi
  mv "$TARGET" "$TARGET.bak.$TIMESTAMP"
elif [[ -e "$TARGET" ]]; then
  mv "$TARGET" "$TARGET.bak.$TIMESTAMP"
fi

ln -s "$SOURCE" "$TARGET"
print -r -- "Installed: $SKILL_NAME -> $TARGET"
