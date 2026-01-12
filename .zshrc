# -----------------------------
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

autoload -Uz colors && colors

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

_killall() {
  local -a processes
  processes=(${(f)"$(ps axo comm= | sort -u)"})
  _describe 'process' processes
}
compdef _killall killall die

# -----------------------------
# SSH
# -----------------------------
if [[ "$OS_NAME" == "arch" ]]; then
  if [[ ! -f /tmp/keychain-initialized-$UID ]]; then
    eval "$(keychain --eval --quiet ~/.ssh/flower ~/.ssh/gh ~/.ssh/qd ~/.ssh/sign)"
    systemctl --user import-environment SSH_AUTH_SOCK
    touch /tmp/keychain-initialized-$UID
  fi
  [[ -f ~/.keychain/$HOST-sh ]] && source ~/.keychain/$HOST-sh
  export SSH_AUTH_SOCK
fi

# -----------------------------
# Env vars
# -----------------------------
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.local/share/gem/ruby/3.4.0/bin:$HOME/.mix/escripts:$PATH"
export EDITOR="micro"
export GPG_TTY=$(tty)
export DEPLOY="rsync -ciavuP --delete --exclude .git --exclude Bakefile"
export TERM="xterm"
export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
export XDG_DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
export XDG_DOCUMENTS_DIR="${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
export XDG_DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
export XDG_MUSIC_DIR="${XDG_MUSIC_DIR:-$HOME/Music}"
export XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
export XDG_PUBLICSHARE_DIR="${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
export XDG_TEMPLATES_DIR="${XDG_TEMPLATES_DIR:-$HOME/Templates}"
export XDG_VIDEOS_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"

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
export LC_TIME=nl_NL.UTF-8

# -----------------------------
# Startup shit
# -----------------------------
if [[ "$OS_NAME" == "arch" ]]; then
  mise() {
    unfunction mise
    eval "$(command mise activate zsh)"
    mise "$@"
  }
fi

if [[ "$OS_NAME" == "ubuntu" ]]; then
  clear
  dec-banner
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
alias lsa="ls -lAh"
alias grep="grep --color=auto"
alias rm="rm -r"
alias qu="exit"
alias open="xdg-open"
alias cl="clear"
alias clip="xclip -selection clipboard"
alias die="killall"

# Package management
if [[ "$OS_NAME" == "arch" ]]; then
  alias gimme="yay -S"
  alias yeet="yay -Rns"
  alias lookup="yay -Ss"
  alias peek="yay -Qi"
elif [[ "$OS_NAME" == "ubuntu" ]]; then
  alias gimme="sudo apt install"
  alias yeet="sudo apt remove"
  alias lookup="apt search"
  alias peek="apt show"
fi

# Custom scripts / shortcuts
alias newproj="$HOME/projects/new_proj.sh"
alias gitcomgraph="$HOME/projects/pers/commitstats/.venv/bin/python $HOME/projects/pers/commitstats/priv2.py"
alias atlas_backup="$HOME/atlas-backups/atlas-backup.sh"
alias dcupdate="$gimme discord"
alias lost="echo '$(whoami)@$HOST:$PWD'"
alias repo="gh repo view --web"
alias qd-vpn="sudo tailscale switch qd && sudo tailscale up --exit-node=qdentity-mac-mini --operator=$USER"
alias qd-vpn-off="sudo tailscale switch du && sudo tailscale up --operator=$USER"

if [[ "$OS_NAME" == "ubuntu" ]]; then
  alias rerouter="docker exec router caddy reload --config /etc/caddy/Caddyfile"
fi

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

# Navigation
if [[ "$OS_NAME" == "arch" ]]; then
  alias tree="exa --tree"
fi

# zshrc shortcuts
alias szrc="source ~/.zshrc"
alias ezrc="e ~/.zshrc"


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
prompt_path() {
  [[ $PWD == $HOME* ]] && echo "~${PWD#$HOME}" || echo "$PWD"
}

build_prompt() {
  local user_host
  local status_indicator=""
  
  if [[ "$USER@$HOST" == "ggijs@lithium" ]]; then
    user_host="%{$fg[yellow]%}%n@%m"
  else
    user_host="%{$fg[red]%}%n@%m"
  fi
  
  echo "%{$fg[green]%}<${user_host}%{$fg[green]%}:%{$fg[blue]%}%~%{$fg[green]%}>%{$reset_color%} "
}

setopt PROMPT_SUBST
PROMPT='$(build_prompt)'
