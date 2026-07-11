---
name: dotfiles-install
description: Install Kamil's full dev environment end-to-end on a fresh Mac from the KamilBlaz/dotfiles repo (nix-darwin, GNU Stow, Homebrew Brewfile, git identities). Use when setting up a new Mac, bootstrapping dotfiles, migrating the dev environment, or the user asks how to install/reproduce their config on another computer.
---

# dotfiles-install

Bootstraps a fresh Apple Silicon Mac to the full dev environment defined in
`github.com/KamilBlaz/dotfiles`: nix-darwin packages, stow-linked dotfiles,
Homebrew GUI apps, and per-directory git identities.

## Quick start

Run the bundled script (does steps 1-7 below):

```bash
~/dotfiles/skills/dotfiles-install/install.sh
```

Or drive it step by step (below) when you want to inspect each stage.

## Prerequisites

- Apple Silicon Mac (`flake.nix` targets `aarch64-darwin`)
- Admin account, internet access

## Workflow

1. **Xcode CLT** (git) - `xcode-select --install` (skip if already present)
2. **Install Nix** (Determinate installer):
   `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
   then open a new shell (`exec zsh`) so `nix` is on PATH.
3. **Clone repo**: `git clone https://github.com/KamilBlaz/dotfiles.git ~/dotfiles`
4. **Backup default zshrc**: `[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.bak`
5. **Build nix-darwin** (installs all CLI packages from `flake.nix`):
   `nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#blaze`
6. **Stow dotfiles** (symlink zshrc, alacritty, git, atuin, aliases into `~`):
   `cd ~/dotfiles && stow .`
7. **Homebrew + GUI apps**:
   - install brew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - `brew bundle --file=~/dotfiles/Brewfile` (see "Manual restores" if the Brewfile is missing)

After step 6, subsequent config changes rebuild with `make rebuild`
(= `darwin-rebuild switch --flake ~/dotfiles#blaze`).

## CRITICAL - do NOT run `nix flake init`

The repo README lists `nix flake init -t nix-darwin` as a step. **Never run it
when reproducing this config** - it overwrites the existing `flake.nix` with an
empty template. Use step 5 (`nix run nix-darwin/master#darwin-rebuild`) to
bootstrap the existing flake instead.

## Manual restores (not in the public repo)

The repo is PUBLIC, so these are intentionally kept out of git and must be
copied from the old Mac (AirDrop / scp):

- **`~/dotfiles/Brewfile`** - Homebrew casks/formulae (GUI apps, CLI tools).
  Regenerate on the source Mac with `brew bundle dump --file=~/dotfiles/Brewfile --force`.
- **`~/.config/git/identities/*.inc`** - per-client git author + GPG identity
  files referenced by `.gitconfig` includeIf rules. Copy the whole
  `~/.config/git/identities/` directory over. Without them, commits in mapped
  project dirs fail to resolve an author.

## Register this skill on the new Mac

`stow` links repo dotfiles into `~`, not into `~/.claude/skills`. To make this
skill invocable by Claude Code on the new machine:

```bash
mkdir -p ~/.claude/skills
ln -sfn ~/dotfiles/skills/dotfiles-install ~/.claude/skills/dotfiles-install
```

## Verify

- `darwin-rebuild --version` and `which nvim fzf atuin kubectl` resolve
- `readlink ~/.zshrc` points into `~/dotfiles`
- `brew bundle check --file=~/dotfiles/Brewfile` reports satisfied
