#!/bin/bash
set -eo pipefail 
# -u: 变量未定义则报错,一旦后续加参数解析（--dry-run / --yes），-u 会频繁误杀,不利于阶段化执行
# -o pipefail: 管道中任意命令失败则整体失败

# XDG directories (mkdir only; not source of truth)
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_BIN_HOME:=$HOME/.local/bin}"
mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_BIN_HOME"
         
echo "XDG directories ensured"

# Host glue (minimal)
if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found; unsupported host"
  exit 1
fi

sudo apt-get update -qq
sudo apt-get install -y -qq \
  ca-certificates \
  curl \
  git

# Linuxbrew
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Load brew env for this script only
if [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d "$HOME/.linuxbrew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

# Minimal first-stage tools
brew install --quiet \
  just \
  chezmoi \
  gh

# Dotfiles bootstrap
DOTFILES_DIR="$XDG_DATA_HOME/chezmoi"
REPO_SSH="git@github.com:zeinsshiri1984/ApexDotfiles.git"
REPO_HTTPS="https://github.com/zeinsshiri1984/ApexDotfiles.git"

if [ -d "$DOTFILES_DIR" ]; then
  echo "Applying existing dotfiles"
  chezmoi apply
else
  echo "Initializing dotfiles"

  if gh auth status >/dev/null 2>&1; then
    echo "Using gh-authenticated clone"
    tmpdir="$(mktemp -d)"
    gh repo clone zeinsshiri1984/ApexDotfiles "$tmpdir"
    chezmoi init --source "$tmpdir" --apply
  elif ssh -o BatchMode=yes -T git@github.com >/dev/null 2>&1; then
    echo "Using SSH clone"
    chezmoi init --apply "$REPO_SSH"
  else
    echo "Using HTTPS clone (may be rate-limited)"
    chezmoi init --apply "$REPO_HTTPS"
  fi
fi

echo "Next step: run 'just setup' to install and configure the environment"