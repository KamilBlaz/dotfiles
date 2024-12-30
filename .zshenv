# Add your exports here
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'
export VISUAL='nvim'
export TERM="xterm-256color"

# Colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export KEYTIMEOUT=1

# Path additions
export PATH="$HOME/neovim/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# Git
export GIT_CONFIG_GLOBAL=~/.config/git/.gitconfig
export GIT_EDITOR="nvim"

# Golang
export GOPATH="$HOME/code/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"

# FZF
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!vendor/*"'
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!vendor/*"'
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"


# Personal bin
export PATH="$HOME/bin:$PATH"

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Additional Go binaries
export PATH=$PATH:$HOME/.local/opt/go/bin




