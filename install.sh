#!/usr/bin/env bash
# Set up a Mac from this repo. Safe to re-run.
#   ./install.sh          install Homebrew + Brewfile, then link dotfiles
#   ./install.sh --link   only link dotfiles
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(zsh git starship gh)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

install_packages() {
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "Installing Xcode Command Line Tools; re-run this script when it finishes."
    xcode-select --install
    exit 1
  fi

  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
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
    done < <(find "$DOTFILES/$pkg" -type f)
  done
}

link_dotfiles() {
  backup_conflicts
  stow --dir "$DOTFILES" --target "$HOME" --no-folding --restow "${PACKAGES[@]}"
  echo "Linked: ${PACKAGES[*]}"
  if [ -d "$BACKUP" ]; then
    echo "Previous files saved in $BACKUP"
  fi
}

if [ "${1:-}" != "--link" ]; then
  install_packages
fi
link_dotfiles
