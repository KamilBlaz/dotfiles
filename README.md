# My dotfiles

This directory contains the dotfiles for my system

## Requirements

Ensure you have the following installed on your system


## Clone repo

```
git clone https://github.com/KamilBlaz/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## Install Nix

```
sh <(curl -L https://nixos.org/nix/install)
```

## Init Nix Flakes

```
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```

## Install Nix Flakes

```
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/dotfiles#blaze
```

stow . 
```
