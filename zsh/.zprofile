# Keep PATH entries unique across re-sourced login shells
typeset -U path

# Homebrew (/opt/homebrew on Apple Silicon, /usr/local on Intel)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Machine-specific or secret settings, not tracked in git
[ -f "$HOME/.zprofile.local" ] && . "$HOME/.zprofile.local"
