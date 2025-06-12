#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Environment Variables
export PATH="$PATH:$HOME/.local/bin"
export EDITOR=micro
export GPG_TTY=$(tty)
export DEPLOY="rsync -ciavuP --delete --exclude .git --exclude Bakefile"

# Keychain & Shell Enhancements
eval $(keychain --eval ~/.ssh/id_ed25519 ~/.ssh/gh)
eval "$(thefuck --alias)"

# Greeting
cowsay "Bonjour! :D" | lolcat

# Aliases
## Core tools
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias rm="rm -r"

## Package management
alias gimme="paru -S"
alias yeet="paru -Rns"
alias lookup="paru -Ss"

## Custom scripts
alias newproj="$HOME/projects/new_proj.sh"

## Python
alias py="python"
alias venva="source .venv/bin/activate"

## Networking
alias pubip="curl ifconfig.me"
alias locip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias serve="python -m http.server 8000"

## Navigation
alias tree="exa --tree"

## Bashrc shortcuts
alias sbrc="source ~/.bashrc"
alias ebrc="e ~/.bashrc"

## Fun
alias moo="fortune | cowsay | lolcat"

## GPU
alias intel="optimus-manager --switch intel --no-confirm"
alias nvidia="optimus-manager --switch nvidia --no-confirm"
alias hybrid="optimus-manager --switch hybrid --no-confirm"
alias gpu="optimus-manager --status"

# Functions

## Shorten PWD
prompt_path() {
  [[ $PWD == $HOME* ]] && echo "~${PWD#$HOME}" || echo "$PWD"
}

## Run last command with sudo
pls() {
  eval "sudo $(fc -ln -1)"
}

## Cat and copy
ccat() {
  cat "$1" | tee >(xclip -selection clipboard)
}

# Prompt
PS1="\[\e[1;32m\]<\u: \[\e[0;34m\]$(prompt_path)\[\e[1;32m\]> \[\e[0m\]"
