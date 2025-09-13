# Exit if not running interactively
[[ $- != *i* ]] && return
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
  return
fi

# -----------------------------
# Basic settings and history
# -----------------------------
HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

unsetopt beep
bindkey -e

# -----------------------------
# Zsh completion initialization
# -----------------------------
zstyle ':compinstall' filename '/home/ggijs/.zshrc'
zstyle ':completion:*' menu select
autoload -Uz compinit
compinit

# -----------------------------
# SSH
# -----------------------------
eval "$(keychain --eval ~/.ssh/flower ~/.ssh/gh ~/.ssh/qd ~/.ssh/sign)"
export SSH_AUTH_SOCK

# -----------------------------
# Env vars
# -----------------------------
export PATH="$HOME/.local/bin:$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH:/home/ggijs/.mix/escripts"
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

# -----------------------------
# Startup shit
# -----------------------------
eval "$(thefuck --alias)"
eval "$(mise activate zsh)"

fortune | cowsay -f tux -W 60 | lolcat --spread=2 --seed=40

# -----------------------------
# Aliases
# -----------------------------
# Core tools
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias rm="rm -r"
alias qu="exit"
alias open="xdg-open"
alias cl="clear"

# Package management
alias gimme="paru -S"
alias yeet="paru -Rns"
alias lookup="paru -Ss"
alias peek="paru -Qi"

# Custom scripts / shortcuts
alias newproj="$HOME/projects/new_proj.sh"
alias gitcomgraph="$HOME/projects/pers/commitstats/.venv/bin/python $HOME/projects/pers/commitstats/priv2.py"
alias dcupdate="paru -Syu discord"
alias lost="echo '$(whoami)@$(hostname):$PWD'"

# Python
alias py="python"
alias venvm="python -m venv .venv && source .venv/bin/activate"
alias venva="source .venv/bin/activate"
alias venvre="rm -rf .venv && python -m venv .venv && source .venv/bin/activate"
alias reqtxt="pip freeze > requirements.txt"

# Just commands I dont want to have to type out all the time
alias ex="elixir"

# Networking
alias pubip="curl -s4 ifconfig.me -w '\n'"
alias locip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias serve="python -m http.server 8000"

# Navigation
alias tree="exa --tree"

# zshrc shortcuts
alias szrc="source ~/.zshrc"
alias ezrc="e ~/.zshrc"

# Fun
alias moo="fortune | cowsay | lolcat"

# GPU management
alias intel="optimus-manager --switch intel --no-confirm"
alias nvidia="optimus-manager --switch nvidia --no-confirm"
alias hybrid="optimus-manager --switch hybrid --no-confirm"
alias gpu="optimus-manager --status"

# -----------------------------
# Functions
# -----------------------------
# Run last command with sudo
pls() {
  sudo $(fc -ln -1)
}

# Cat and copy to clipboard
ccat() {
  cat "$1" | tee >(xclip -selection clipboard)
}

# -----------------------------
# Prompt
# -----------------------------
autoload -Uz colors && colors

prompt_path() {
  [[ $PWD == $HOME* ]] && echo "~${PWD#$HOME}" || echo "$PWD"
}

build_prompt() {
  local user_host
  local status_indicator=""
  
  if [[ "$USER@$HOST" == "ggijs@flaptop" ]] || [[ "$USER@$(hostname)" == "ggijs@flaptop" ]]; then
    user_host="%{$fg[yellow]%}%n@%m"
  else
    user_host="%{$fg[red]%}%n@%m"
  fi
  
  echo "%{$fg[green]%}<${user_host}:%{$fg[blue]%}%~%{$fg[green]%}>%{$reset_color%} "
}

setopt PROMPT_SUBST
PROMPT='$(build_prompt)'
