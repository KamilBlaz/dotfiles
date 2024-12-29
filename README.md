# My dotfiles

<img src="https://nixos.org/logo/nixos-logo-only-hires.png" alt="Nix" width="200"/>


This directory contains the dotfiles for my system

## Requirements

Ensure you have the following installed on your system


## Clone repo

```
git clone https://github.com/KamilBlaz/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Backup zsh

```
mv ~/.zshrc ~/.zshrc.bak
```

## Install Nix

```
sh <(curl -L https://nixos.org/nix/install)
```

## Init Nix Flakes

```
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```

## Rebuild Nix Flakes

```
 darwin-rebuild switch --flake ~/dotfiles#blaze
```

## Stow

```
stow . 
```
