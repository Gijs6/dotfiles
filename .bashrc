#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Environment Variables ---
export PATH="$PATH:$HOME/.local/bin"
export EDITOR=micro
export GPG_TTY=$(tty)
export DEPLOY="rsync -ciavuP --delete --exclude .git --exclude Bakefile"

# Keychain (SSH Agent)
eval $(keychain --eval ~/.ssh/id_ed25519)

# Greeting
cowsay "Bonjour! :D" | lolcat

# Aliases
## Core tools
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rm="rm -r" # Allow to remove directories

## Package management
alias gimme="paru -S"
alias yeet="paru -Rns"
alias lookup="paru -Ss"

## Scripts and shortcuts
alias newproj="$HOME/projects/new_proj.sh"
alias 2fa="PASSWORD_STORE_DIR=$HOME/.2fa pass otp"
alias venva="source .venv/bin/activate"

## GPU
alias intel="optimus-manager --switch intel --no-confirm"
alias nvidia="optimus-manager --switch nvidia --no-confirm"
alias hybrid="optimus-manager --switch hybrid --no-confirm"
alias gpu="optimus-manager --status"

# Functions

## Quick edit the bashrc
ebrc() {
   e ~/.bashrc
}

## Function to shorten $PWD to ~ if under $HOME
prompt_path() {
  if [[ $PWD == $HOME* ]]; then
    echo "~${PWD#$HOME}"
  else
    echo "$PWD"
  fi
}

## Runs the last command but then with sudo
pls() {
  eval "sudo $(fc -ln -1)"
}

# Prompt
PS1='\[\e[1;32m\]<\u: \[\e[0;34m\]$(prompt_path)\[\e[1;32m\]> \[\e[0m\]'
