# HISTSIZE and SAVEHIST set the size of your history
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE

# EXTENDED_HISTORY saves the timestamp of each command in the history
setopt EXTENDED_HISTORY

# change directories as default command without typing cd
setopt autocd

# Homebrew-installed completions (gh, pnpm, etc.) must be on fpath before compinit
if [ -n "$HOMEBREW_PREFIX" ]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

# enable in-built zsh command auto-completion
autoload -U compinit; compinit

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# rbenv
command -v rbenv >/dev/null && eval "$(rbenv init - zsh)"

# Node via Vite+ (https://viteplus.dev): shims for node/npm/npx, resolved per project.
# Sourced after compinit so it can register its completions; it moves its shims to the front of PATH.
[ -f "$HOME/.config/vite-plus/env" ] && . "$HOME/.config/vite-plus/env"

# Fuzzy command history search
command -v fzf >/dev/null && source <(fzf --zsh)

# Aliases and functions
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Machine-specific or secret settings, not tracked in git
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# Customizable prompt with starship.rs
command -v starship >/dev/null && eval "$(starship init zsh)"
