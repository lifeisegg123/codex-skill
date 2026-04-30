# Codex Skills

Repository for reusable Codex skills.

## Layout

```text
skills/
  mac-terminal-setup/
    SKILL.md
    agents/
    assets/
    scripts/
scripts/
  install-skill.zsh
  install-all.zsh
  validate-skills.zsh
```

Each directory under `skills/` is a complete Codex skill folder. Keep skill-specific scripts and assets inside that skill directory.

## Install

Install one skill into Codex's discovery path:

```bash
./scripts/install-skill.zsh mac-terminal-setup
```

Install every skill in this repository:

```bash
./scripts/install-all.zsh
```

By default, install scripts create symlinks in `${CODEX_HOME:-$HOME/.codex}/skills` so pulling this repository updates the installed skills. If an installed skill already exists and is not the expected symlink, it is moved to a timestamped backup before linking.

## Validate

Run repository-level validation:

```bash
./scripts/validate-skills.zsh
```

This checks the expected skill folder structure, `SKILL.md` frontmatter basics, UI metadata, and bundled zsh script syntax.

## Publish

This repository is configured for:

```bash
git remote -v
git status --short --branch
git push origin main
```

Only push when you intentionally want to publish the local commits.
