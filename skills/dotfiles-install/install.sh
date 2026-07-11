#!/usr/bin/env bash
# End-to-end bootstrap of the dev environment on a fresh Apple Silicon Mac.
# Repo: https://github.com/KamilBlaz/dotfiles
# Safe to re-run: each step checks whether it is already done.
set -euo pipefail

REPO_URL="https://github.com/KamilBlaz/dotfiles.git"
DOTFILES="${HOME}/dotfiles"
FLAKE="${DOTFILES}#blaze"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

# 0. Sanity: Apple Silicon only (flake targets aarch64-darwin)
if [ "$(uname -m)" != "arm64" ]; then
  echo "This config targets Apple Silicon (aarch64-darwin). Aborting." >&2
  exit 1
fi

# 1. Xcode Command Line Tools (provides git)
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (approve the GUI prompt, then re-run)"
  xcode-select --install || true
  echo "Re-run this script after the CLT install finishes." >&2
  exit 0
fi

# 2. Nix (Determinate installer)
if ! have nix; then
  log "Installing Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # Load nix into the current shell for the rest of this run
  if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
else
  log "Nix already installed - skipping"
fi

# 3. Clone dotfiles
if [ ! -d "${DOTFILES}/.git" ]; then
  log "Cloning dotfiles into ${DOTFILES}"
  git clone "${REPO_URL}" "${DOTFILES}"
else
  log "Dotfiles repo already present - skipping clone"
fi

# 4. Back up any default zshrc that is not our symlink
if [ -f "${HOME}/.zshrc" ] && [ ! -L "${HOME}/.zshrc" ]; then
  log "Backing up existing ~/.zshrc to ~/.zshrc.bak"
  mv "${HOME}/.zshrc" "${HOME}/.zshrc.bak"
fi

# 5. Build nix-darwin (installs all CLI packages from flake.nix)
#    NOTE: never `nix flake init` here - it would overwrite flake.nix.
log "Building nix-darwin system (this pulls all packages, be patient)"
nix run nix-darwin/master#darwin-rebuild -- switch --flake "${FLAKE}"

# 6. Stow dotfiles into $HOME
log "Linking dotfiles with stow"
( cd "${DOTFILES}" && stow . )

# 7. Homebrew + Brewfile (GUI apps / extra CLI)
if ! have brew; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [ -f "${DOTFILES}/Brewfile" ]; then
  log "Installing Homebrew bundle"
  brew bundle --file="${DOTFILES}/Brewfile"
else
  echo "!! No ${DOTFILES}/Brewfile found - copy it from the old Mac and run:"
  echo "   brew bundle --file=${DOTFILES}/Brewfile"
fi

# 8. Register this skill for Claude Code on the new machine
mkdir -p "${HOME}/.claude/skills"
ln -sfn "${DOTFILES}/skills/dotfiles-install" "${HOME}/.claude/skills/dotfiles-install"

log "Done. Manual restores still needed (not in the public repo):"
echo "  - ~/.config/git/identities/*.inc  (copy from old Mac via AirDrop)"
echo "  - ~/dotfiles/Brewfile              (if it was missing above)"
echo "Future rebuilds: make rebuild  (in ~/dotfiles)"
