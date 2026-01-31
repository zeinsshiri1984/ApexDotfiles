#!/bin/bash
set -eo pipefail
# -u: 变量未定义则报错,一旦后续加参数解析（--dry-run / --yes），-u 会频繁误杀,不利于阶段化执行
# -o pipefail: 管道中任意命令失败则整体失败

# XDG directories (mkdir only; not source of truth)
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"

mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$XDG_CACHE_HOME" \
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
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || { echo "brew install failed"; exit 1; }
fi

# Load brew env for this script only (DO NOT persist)
BREW_BIN=""
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  BREW_BIN="$HOME/.linuxbrew/bin/brew"
elif command -v brew >/dev/null 2>&1; then
  BREW_BIN="$(command -v brew)"
fi

if [ -z "$BREW_BIN" ]; then
  echo "brew not found after install"
  exit 1
fi

eval "$("$BREW_BIN" shellenv)" || {
  echo "failed to load brew env"
  exit 1
}

# Minimal first-stage tools
for pkg in just chezmoi gh mise; do
  if ! command -v "$pkg" >/dev/null 2>&1; then
    brew install --quiet "$pkg"
  fi
done

# Dotfiles bootstrap
# Collect prompt data once
CHEZMOI_PROMPT_ARGS=()
name="$(git config --global user.name 2>/dev/null || true)"
email="$(git config --global user.email 2>/dev/null || true)"

if [ -n "$name" ] && [ -n "$email" ]; then
  CHEZMOI_PROMPT_ARGS=(
    --promptString "name=$name"
    --promptString "email=$email"
  )
fi

TMP_SRC="$XDG_DATA_HOME/apexdotfiles-tmp"
rm -rf "$TMP_SRC"

if gh auth status >/dev/null 2>&1; then
  gh repo clone zeinsshiri1984/ApexDotfiles "$TMP_SRC"
elif ssh -o BatchMode=yes -T git@github.com >/dev/null 2>&1; then
  git clone git@github.com:zeinsshiri1984/ApexDotfiles.git "$TMP_SRC"
else
  git clone https://github.com/zeinsshiri1984/ApexDotfiles.git "$TMP_SRC"
fi

chezmoi init --source "$TMP_SRC" --apply "${CHEZMOI_PROMPT_ARGS[@]}"
rm -rf "$TMP_SRC"

JUSTFILE="$XDG_CONFIG_HOME/just/justfile"
if command -v just >/dev/null 2>&1 && [ -f "$JUSTFILE" ]; then
  just --justfile "$JUSTFILE" setup
fi

echo "Bootstrap complete."
