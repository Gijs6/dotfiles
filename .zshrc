# -----------------------------
# Detect OS
# -----------------------------
if [[ -f /etc/os-release ]]; then
  source /etc/os-release
  OS_NAME=$ID
else
  OS_NAME="unknown"
fi

# -----------------------------
# Exit if not running interactively, except on host 'december'
# -----------------------------
if [[ $- != *i* ]]; then
  return
fi

# Skip GUI-only stuff unless on host 'december' or FORCE_SOURCE is set
if [[ "$HOST" != "december" && -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && -z "$FORCE_SOURCE" ]]; then
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
setopt autocd
setopt auto_pushd pushd_ignore_dups

unsetopt beep
bindkey -e

# -----------------------------
# Zsh completion initialization
# -----------------------------
zstyle ':compinstall' filename "$HOME/.zshrc"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

autoload -Uz compinit
compinit

# -----------------------------
# SSH
# -----------------------------
if [[ "$OS_NAME" == "arch" ]]; then
  eval "$(keychain --eval ~/.ssh/flower ~/.ssh/gh ~/.ssh/qd ~/.ssh/sign)"
  export SSH_AUTH_SOCK
fi

# -----------------------------
# Env vars
# -----------------------------
export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.local/share/gem/ruby/3.4.0/bin:$HOME/.mix/escripts"
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
if [[ "$OS_NAME" == "arch" ]]; then
  eval "$(thefuck --alias)"
  eval "$(mise activate zsh)"

  fortune | cowsay -f tux -W 60 | lolcat --spread=2 --seed=40
fi

# -----------------------------
# Plugins
# -----------------------------
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

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
alias clip="xclip -selection clipboard"

# Package management
if [[ "$OS_NAME" == "arch" ]]; then
  alias gimme="paru -S"
  alias yeet="paru -Rns"
  alias lookup="paru -Ss"
  alias peek="paru -Qi"
elif [[ "$OS_NAME" == "ubuntu" ]]; then
  alias gimme="sudo apt install"
  alias yeet="sudo apt remove"
  alias lookup="apt search"
  alias peek="apt show"
fi

# Custom scripts / shortcuts
alias newproj="$HOME/projects/new_proj.sh"
alias gitcomgraph="$HOME/projects/pers/commitstats/.venv/bin/python $HOME/projects/pers/commitstats/priv2.py"
alias atlas_backup="$HOME/scripts/atlas-backup.sh"
alias dcupdate="$gimme discord"
alias lost="echo '$(whoami)@$(hostname):$PWD'"

# Python
alias py="python"
alias venvm="python -m venv .venv && source .venv/bin/activate"
alias venva="source .venv/bin/activate"
alias venvre="rm -rf .venv && python -m venv .venv && source .venv/bin/activate"
alias reqtxt="pip freeze > requirements.txt"

# Elixir
alias ex="elixir"

# Networking
alias pubip="curl -s4 ifconfig.me -w '\n'"
alias locip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias serve="python -m http.server 8000"

# Navigation
if [[ "$OS_NAME" == "arch" ]]; then
  alias tree="exa --tree"
fi

# zshrc shortcuts
alias szrc="source ~/.zshrc"
alias ezrc="e ~/.zshrc"

if [[ "$OS_NAME" == "arch" ]]; then
  # GPU management
  alias intel="optimus-manager --switch intel --no-confirm"
  alias nvidia="optimus-manager --switch nvidia --no-confirm"
  alias hybrid="optimus-manager --switch hybrid --no-confirm"
  alias gpu="optimus-manager --status"
fi

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

# Extract archives
extract() {
  local archive="$1"
  local outdir="${2:-.}"

  if [[ -z "$archive" ]]; then
    echo "Usage: extract <archive> [output_dir]"
    return 1
  fi

  mkdir -p "$outdir" || return 1

  case "$archive" in
    *.tar.bz2) tar xjf "$archive" -C "$outdir" ;;
    *.tar.gz)  tar xzf "$archive" -C "$outdir" ;;
    *.bz2)     bunzip2 -c "$archive" > "$outdir/$(basename "${archive%.bz2}")" ;;
    *.rar)     unrar x "$archive" "$outdir/" ;;
    *.gz)      gunzip -c "$archive" > "$outdir/$(basename "${archive%.gz}")" ;;
    *.tar)     tar xf "$archive" -C "$outdir" ;;
    *.tbz2)    tar xjf "$archive" -C "$outdir" ;;
    *.tgz)     tar xzf "$archive" -C "$outdir" ;;
    *.zip)     unzip -d "$outdir" "$archive" ;;
    *.Z)       uncompress -c "$archive" > "$outdir/$(basename "${archive%.Z}")" ;;
    *.7z)      7z x "$archive" -o"$outdir" ;;
    *) echo "Don't know how to extract '$archive'..." ;;
  esac
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
