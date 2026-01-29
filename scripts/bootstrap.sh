#!/bin/bash
set -eo pipefail 
# -u: 变量未定义则报错,一旦后续加参数解析（--dry-run / --yes），-u 会频繁误杀,不利于阶段化执行
# -o pipefail: 管道中任意命令失败则整体失败

# XDG directories (mkdir only; not source of truth)
mkdir -p \
  "$HOME/.config" \
  "$HOME/.local/share" \
  "$HOME/.local/state" \
  "$HOME/.cache" \
  "$HOME/.local/bin"
         
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

# Load brew env for this script only (DO NOT persist)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

# Minimal first-stage tools
brew install --quiet \
  just \
  chezmoi \
  gh \
  mise

# Dotfiles bootstrap
DOTFILES_DIR="$HOME/.local/share/chezmoi"
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

echo "Bootstrap complete."