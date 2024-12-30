##############
# BASIC SETUP
##############

typeset -U PATH
autoload colors; colors;

#############
## PRIVATE ##
#############
# Include private stuff that's not supposed to show up
# in the dotfiles repo
local private="${HOME}/.zsh.d/private.sh"
if [ -e ${private} ]; then
  . ${private}
fi

##########
# HISTORY
##########


HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt INC_APPEND_HISTORY     # Immediately append to history file.
setopt EXTENDED_HISTORY       # Record timestamp in history.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS       # Dont record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS   # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS      # Do not display a line previously found.
setopt HIST_IGNORE_SPACE      # Dont record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS      # Dont write duplicate entries in the history file.
setopt SHARE_HISTORY          # Share history between all sessions.
unsetopt HIST_VERIFY          # Execute commands using history (e.g.: using !$) immediately

#############
# COMPLETION
#############

# Add completions installed through Homebrew packages
# See: https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null; then
  FPATH=/usr/local/share/zsh/site-functions:$FPATH
fi

# Speed up completion init, see: https://gist.github.com/ctechols/ca1035271ad134841284
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# unsetopt menucomplete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt auto_pushd

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


# [f]uzzy check[o]ut
fo() {
  git branch --no-color --sort=-committerdate --format='%(refname:short)' | fzf --header 'git checkout' | xargs git checkout
}
# [p]ull request check[o]ut
po() {
  gh pr list --author "@me" | fzf --header 'checkout PR' | awk '{print $(NF-5)}' | xargs git checkout
}

##########
# FUNCTIONS
##########

mkdircd() {
  mkdir -p $1 && cd $1
}

beautiful() {
  while
  do
    i=$((i + 1)) && echo -en "\x1b[3$(($i % 7))mo" && sleep .2
  done
}

spinner() {
  while
  do
    for i in "-" "\\" "|" "/"
    do
      echo -n " $i \r\r"
      sleep .1
    done
  done
}


s3() { 
  local route="s3.example.com/${1}"
  aws s3 cp ${1} s3://${route}
  echo http://${route} | pbcopy
}

# Open PR on GitHub
pr() {
  if type gh &> /dev/null; then
    gh pr view -w
  else
    echo "gh is not installed"
  fi
}

#########
# PROMPT
#########

setopt prompt_subst

git_prompt_info() {
  local dirstatus=" OK"
  local dirty="%{$fg_bold[red]%} X%{$reset_color%}"

  if [[ ! -z $(git status --porcelain 2> /dev/null | tail -n1) ]]; then
    dirstatus=$dirty
  fi

  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo " %{$fg_bold[green]%}${ref#refs/heads/}$dirstatus%{$reset_color%}"
}

local dir_info_color="%B"

local dir_info_color_file="${HOME}/.zsh.d/dir_info_color"
if [ -r ${dir_info_color_file} ]; then
  source ${dir_info_color_file}
fi

local dir_info="%{$dir_info_color%}%(5~|%-1~/.../%2~|%4~)%{$reset_color%}"
local promptnormal="φ %{$reset_color%}"
local promptjobs="%{$fg_bold[red]%}φ %{$reset_color%}"

# Show how many nested `nix shell`s we are in

PROMPT='${dir_info}$(git_prompt_info) ${nix_prompt}%(1j.$promptjobs.$promptnormal)'

simple_prompt() {
  local prompt_color="%B"
  export PROMPT="%{$prompt_color%}$promptnormal"
}

########
# ENV
########

case $OSTYPE in
  linux*)
    local envfile="${HOME}/.zsh.d/env.Linux.sh"
    [[ -e ${envfile} ]] && source ${envfile}
  ;;
  darwin*)
    local envfile="${HOME}/.zsh.d/env.Darwin.sh"
    [[ -e ${envfile} ]] && source ${envfile}
  ;;
esac


if type nvim &> /dev/null; then
  alias vim="nvim"
  export EDITOR="nvim"
  export PSQL_EDITOR="nvim -c"set filetype=sql""
  export GIT_EDITOR="nvim"
else
  export EDITOR='vim'
  export PSQL_EDITOR='vim -c"set filetype=sql"'
  export GIT_EDITOR='vim'
fi

if [[ -e "$HOME/code/clones/lua-language-server/3rd/luamake/luamake" ]]; then
  alias luamake="$HOME/code/clones/lua-language-server/3rd/luamake/luamake"
fi


# direnv
if type direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf
if type fzf &> /dev/null && type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!vendor/*"'
  export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!vendor/*"'
  export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Try out atuin
if type atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi

# `z`
if [ -e /usr/local/etc/profile.d/z.sh ]; then
  source /usr/local/etc/profile.d/z.sh
fi

if [ -e /opt/homebrew/etc/profile.d/z.sh ]; then
  source /opt/homebrew/etc/profile.d/z.sh
fi


bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Add Homebrew to PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Rosetta 2 (Intel apps)
eval "$(/usr/local/bin/brew shellenv)"
eval "$(zoxide init zsh)"


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

[[ -s "/Users/kamilblaz/.gvm/scripts/gvm" ]] && source "/Users/kamilblaz/.gvm/scripts/gvm"


# Aliases
# Source the aliases file
[[ -f ~/.aliases ]] && source ~/.aliases