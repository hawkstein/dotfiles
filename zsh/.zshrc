# HISTSIZE and SAVEHIST set the size of your history
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE

# EXTENDED_HISTORY saves the timestamp of each command in the history
setopt EXTENDED_HISTORY

# change directories as default command without typing cd
setopt autocd

# enable in-built zsh command auto-completion
autoload -U compinit; compinit

# Fuzzy command history search
source <(fzf --zsh)

# Customizable prompt with starship.rs
eval "$(starship init zsh)"