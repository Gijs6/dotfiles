# Exit if not running interactively

[[ $- != *i* ]] && return
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
  return
fi

# Basic Settings and History

HISTFILE=~/.histfile
HISTSIZE=100
SAVEHIST=1000
unsetopt beep
bindkey -e

# Zsh Completion Initialization

zstyle ':compinstall' filename '/home/ggijs/.zshrc'
zstyle ':completion:*' menu select
autoload -Uz compinit
compinit

# Environment Variables

export PATH="$HOME/.local/bin:$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
export EDITOR="micro"
export GPG_TTY=$(tty)
export DEPLOY="rsync -ciavuP --delete --exclude .git --exclude Bakefile"
export TERM="xterm"

export MASTER_DB_PARAMS="host=34.76.242.173 \
                         sslrootcert=$HOME/.qsecrets/master-db/server-ca.pem \
                         sslcert=$HOME/.qsecrets/master-db/client-cert.pem \
                         sslkey=$HOME/.qsecrets/master-db/client-key.pem \
                         sslmode=verify-ca"
export QDENTITY_DB_PARAMS="host=35.233.53.53 \
                         sslrootcert=$HOME/.qsecrets/qdentity-db/server-ca.pem \
                         sslcert=$HOME/.qsecrets/qdentity-db/client-cert.pem \
                         sslkey=$HOME/.qsecrets/qdentity-db/client-key.pem \
                         sslmode=verify-ca"

export LC_CTYPE=en_GB.UTF-8


# Skip in TTY
eval "$(keychain --eval ~/.ssh/id_ed25519 ~/.ssh/gh ~/.ssh/qd)"
eval "$(thefuck --alias)"


fortune | cowsay -f tux -W 60 | lolcat --spread=2 --seed=40

# Aliases

## Core tools
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias rm="rm -r"
alias qu="exit"

## Package management
alias gimme="paru -S"
alias yeet="paru -Rns"
alias lookup="paru -Ss"
alias peeek="paru -Qi"

## Custom scripts/shortcuts
alias newproj="$HOME/projects/new_proj.sh"
alias gitcomgraph="$HOME/projects/pers/commitstats/.venv/bin/python $HOME/projects/pers/commitstats/priv2.py"
alias dcupdate="paru -Syu discord" # For when the discord updater bugs again

## Python
alias py="python"
alias venvm="python -m venv .venv && source .venv/bin/activate"
alias venva="source .venv/bin/activate"
alias venvre="rm -rf .venv && python -m venv .venv && source .venv/bin/activate"
alias reqtxt="pip freeze > requirements.txt"
alias "pip i"="pip install"

## Elixir
alias ex="elixir"

## Networking
alias pubip="curl -s4 ifconfig.me -w '\n'"
alias locip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias serve="python -m http.server 8000"

## Navigation
alias tree="exa --tree"

## zshrc shortcuts
alias szrc="source ~/.zshrc"
alias ezrc="e ~/.zshrc"

## Fun
alias moo="fortune | cowsay | lolcat"

## GPU management
alias intel="optimus-manager --switch intel --no-confirm"
alias nvidia="optimus-manager --switch nvidia --no-confirm"
alias hybrid="optimus-manager --switch hybrid --no-confirm"
alias gpu="optimus-manager --status"

# Functions

## Run last command with sudo
pls() {
  sudo $(fc -ln -1)
}

## Cat and copy to clipboard
ccat() {
  cat "$1" | tee >(xclip -selection clipboard)
}

# Prompt

autoload -Uz colors && colors

prompt_path() {
  [[ $PWD == $HOME* ]] && echo "~${PWD#$HOME}" || echo "$PWD"
}

PROMPT="%{$fg[green]%}<%n@%m:%{$fg[blue]%}%~%{$fg[green]%}> %{$reset_color%}"

eval "$(mise activate zsh)"
