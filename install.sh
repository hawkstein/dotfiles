#!/usr/bin/env bash
# Set up a Mac from this repo. Safe to re-run.
#   ./install.sh          install Homebrew + Brewfile, then link dotfiles
#   ./install.sh --link   only link dotfiles
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(zsh git starship gh)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Put Homebrew on PATH (/opt/homebrew on Apple Silicon, /usr/local on Intel).
# Fails if Homebrew isn't installed in either place.
load_brew() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    return 1
  fi
}

install_packages() {
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing Xcode Command Line Tools; re-run this script when it finishes."
    xcode-select --install
    exit 1
  fi

  if ! load_brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if ! load_brew; then
      echo "Homebrew didn't install; see above." >&2
      exit 1
    fi
  fi

  brew bundle --file "$DOTFILES/Brewfile" || echo "Some Brewfile entries failed; see above."
}

# Move anything that would block a symlink out of the way: real files and
# symlinks (including dangling ones) that don't already point at this repo
backup_conflicts() {
  local pkg file target
  for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r file; do
      target="$HOME/${file#"$DOTFILES/$pkg/"}"
      if { [ -e "$target" ] || [ -L "$target" ]; } && [ ! "$target" -ef "$file" ]; then
        mkdir -p "$BACKUP/$(dirname "${target#"$HOME/"}")"
        mv "$target" "$BACKUP/${target#"$HOME/"}"
        echo "Backed up $target"
      fi
    # Skip the files stow is told to ignore in link_dotfiles
    done < <(find "$DOTFILES/$pkg" -type f ! -name .DS_Store)
  done
}

link_dotfiles() {
  # Check for stow before moving anything, so a missing stow can't leave
  # $HOME with its dotfiles backed up but nothing linked in their place
  load_brew || true
  if ! command -v stow >/dev/null; then
    echo "GNU Stow isn't installed. Run ./install.sh (or brew install stow) first." >&2
    exit 1
  fi

  backup_conflicts
  # Keep --ignore in sync with the find in backup_conflicts
  if ! stow --dir "$DOTFILES" --target "$HOME" --no-folding --ignore='\.DS_Store' \
      --restow "${PACKAGES[@]}"; then
    echo "stow failed; see above." >&2
    if [ -d "$BACKUP" ]; then
      echo "Your previous files are in $BACKUP; move them back to restore them." >&2
    fi
    exit 1
  fi
  echo "Linked: ${PACKAGES[*]}"
  if [ -d "$BACKUP" ]; then
    echo "Previous files saved in $BACKUP"
  fi
}

if [ "${1:-}" != "--link" ]; then
  install_packages
fi
link_dotfiles
