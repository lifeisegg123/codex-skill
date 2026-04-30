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
