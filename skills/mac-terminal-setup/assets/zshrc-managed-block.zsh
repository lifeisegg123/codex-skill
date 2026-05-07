# mac-terminal-setup: mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# mac-terminal-setup: Zinit plugin manager
if command -v brew >/dev/null 2>&1; then
  ZINIT_HOME="$(brew --prefix)/opt/zinit"
  if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
    source "$ZINIT_HOME/zinit.zsh"

    # Zsh plugins loaded with Zinit Turbo mode.
    zinit wait lucid light-mode for \
      blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
      atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
      atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting
  fi
fi

# mac-terminal-setup: searchable shell history
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# mac-terminal-setup: side-by-side git diff viewer
_mac_terminal_setup_delta() {
  delta \
    --side-by-side \
    --line-numbers \
    --wrap-max-lines=unlimited \
    "--word-diff-regex=[^[:space:]]+" \
    --paging=always
}

_mac_terminal_setup_delta_wide() {
  local width="${CHANGES_DIFF_WIDTH:-240}"

  DELTA_PAGER="${DELTA_PAGER:-less -RXS}" delta \
    --side-by-side \
    --line-numbers \
    --wrap-max-lines=0 \
    --width="$width" \
    "--word-diff-regex=[^[:space:]]+" \
    --paging=always
}

changes() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    print -u2 "changes: not inside a git repository"
    return 1
  }

  if command -v delta >/dev/null 2>&1; then
    {
      print "Repository changes"
      print "=================="
      git status --short
      print ""
      git diff --color=always "$@"
    } | _mac_terminal_setup_delta
  else
    git status --short
    git diff "$@"
  fi
}

changes-wide() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    print -u2 "changes-wide: not inside a git repository"
    return 1
  }

  if command -v delta >/dev/null 2>&1; then
    {
      print "Repository changes"
      print "=================="
      git status --short
      print ""
      git diff --color=always "$@"
    } | _mac_terminal_setup_delta_wide
  else
    git status --short
    git diff "$@"
  fi
}

changes-staged() {
  if command -v delta >/dev/null 2>&1; then
    git diff --cached --color=always "$@" | _mac_terminal_setup_delta
  else
    git diff --cached "$@"
  fi
}

changes-last() {
  if command -v delta >/dev/null 2>&1; then
    git show --color=always --stat --patch "${1:-HEAD}" | _mac_terminal_setup_delta
  else
    git show --stat --patch "${1:-HEAD}"
  fi
}

# mac-terminal-setup: Warp-like prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# mac-terminal-setup: collapse previous prompts in scrollback.
if typeset -f zinit >/dev/null 2>&1; then
  TRANSIENT_PROMPT_PROMPT=$PROMPT
  TRANSIENT_PROMPT_RPROMPT=$RPROMPT
  TRANSIENT_PROMPT_TRANSIENT_PROMPT='%F{green}%#%f '
  TRANSIENT_PROMPT_TRANSIENT_RPROMPT=''
  zinit light olets/zsh-transient-prompt
fi
