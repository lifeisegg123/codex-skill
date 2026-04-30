#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
SKILLS_ROOT="$REPO_ROOT/skills"
FAILED=0

fail() {
  print -u2 -- "FAIL: $*"
  FAILED=1
}

pass() {
  print -r -- "OK: $*"
}

validate_skill() {
  local skill_dir="$1"
  local name="${skill_dir:t}"
  local skill_md="$skill_dir/SKILL.md"
  local openai_yaml="$skill_dir/agents/openai.yaml"

  [[ -f "$skill_md" ]] || {
    fail "$name missing SKILL.md"
    return
  }

  grep -q '^---$' "$skill_md" || fail "$name SKILL.md missing frontmatter markers"
  grep -q "^name: $name$" "$skill_md" || fail "$name SKILL.md name does not match folder"
  grep -q '^description: .' "$skill_md" || fail "$name SKILL.md missing description"
  grep -q 'TODO' "$skill_md" && fail "$name SKILL.md still contains TODO"

  if [[ -f "$openai_yaml" ]]; then
    grep -q '^interface:' "$openai_yaml" || fail "$name agents/openai.yaml missing interface"
    grep -q 'default_prompt: ".*\$' "$openai_yaml" || fail "$name agents/openai.yaml default_prompt should mention the skill"
  fi

  for script in "$skill_dir"/scripts/*.zsh(N); do
    zsh -n "$script" || fail "$name script syntax failed: $script"
  done

  pass "$name"
}

if [[ ! -d "$SKILLS_ROOT" ]]; then
  fail "missing skills directory: $SKILLS_ROOT"
  exit 1
fi

for skill_dir in "$SKILLS_ROOT"/*(/N); do
  validate_skill "$skill_dir"
done

for script in "$REPO_ROOT"/scripts/*.zsh(N); do
  zsh -n "$script" || fail "repo script syntax failed: $script"
done

if (( FAILED )); then
  exit 1
fi

print -r -- "All skills are valid."
