# dotfiles

Each top-level folder is a [GNU Stow](https://www.gnu.org/software/stow/) package laid out
as it should appear in `$HOME`:

| Package    | Links                                                  |
| ---------- | ------------------------------------------------------ |
| `zsh`      | `~/.zshrc`, `~/.zprofile`, `~/.config/zsh/aliases.zsh` |
| `git`      | `~/.gitconfig`, `~/.config/git/ignore`                 |
| `starship` | `~/.config/starship.toml`                              |
| `gh`       | `~/.config/gh/config.yml`                              |

## New Mac

```sh
xcode-select --install
git clone https://github.com/hawkstein/dotfiles.git ~/Projects/dotfiles
~/Projects/dotfiles/install.sh
```

`install.sh` installs Homebrew and everything in the `Brewfile`, moves any existing files it
would replace into `~/.dotfiles-backup/`, then links the packages. Use `./install.sh --link`
to only relink.

Then:

- Install [Vite+](https://viteplus.dev) (using to manage Node instead of `nvm`), [rustup](https://rustup.rs) and [bun](https://bun.sh)
- Set the iTerm2 font to **Inconsolata Nerd Font** for starship's symbols
- `gh auth login`

Optional:

- `brew bundle --file ~/Projects/dotfiles/Brewfile.extra`

## Not in this repo

- Machine-specific settings go in `~/.zprofile.local` or `~/.zshrc.local`
- Secrets, tokens and SSH keys should be kept in 1Password
