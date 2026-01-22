#!/bin/bash
set -euo pipefail

echo "🚀 Apex DevEnv Bootstrap (Phase 1)..."
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export PATH="$HOME/.local/bin:$PATH"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# OS Detection
OS_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
IS_IMMUTABLE=0
WSL_FLAG=0
GUI_FLAG=0

if [ -f /run/ostree-booted ] || [ -f /etc/fedora-backward-compatibility ]; then
    echo "❄️  Immutable OS detected ($OS_ID)"
    IS_IMMUTABLE=1
fi

# WSL Detection
if [ -n "${WSL_DISTRO_NAME-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
    echo "🪟 WSL detected"
    WSL_FLAG=1
fi

# GUI Detection (Simple check for DISPLAY or Wayland)
if [ -n "${DISPLAY-}" ] || [ -n "${WAYLAND_DISPLAY-}" ]; then
    GUI_FLAG=1
fi

# 1. Install Mise (The Manager)
if ! command -v mise &> /dev/null; then
    echo "📦 Installing mise..."
    curl https://mise.run | sh
fi

eval "$($HOME/.local/bin/mise activate bash)"
mise use -g chezmoi bw gh just

if ! command -v devbox &> /dev/null; then
    echo "📦安装devbox"
    curl -fsSL https://get.jetify.com/devbox | bash
fi

if ! gh auth status &>/dev/null; then
    if [ "$GUI_FLAG" -eq 1 ] && [ "$WSL_FLAG" -eq 0 ]; then
        echo "🔑 正在通过 GitHub CLI 认证..."
        gh auth login -p ssh -w --git-protocol ssh
    else
        echo "🔑 跳过 GUI 交互式 GitHub 认证"
    fi
fi

if [ ! -d "$XDG_DATA_HOME/chezmoi" ]; then
    echo "📦 初始化 Dotfiles..."
    chezmoi init --apply git@github.com:zeinsshiri1984/ApexDotfiles.git
else
    echo "🔄 Updating dotfiles..."
    chezmoi apply --keep-going
fi

# 4. Install All Tools defined in config.toml
echo "📦 Installing all user environment tools via mise..."
mise install -y

# 5. Shell Setup
# We use bash as the login shell, which execs nu in interactive mode via .bashrc
# So we don't force change shell to nu anymore, but we can ensure bash is default if needed.
# For Immutable OS, we rely on the user's terminal emulator or OS default being bash.

echo "🎉 Apex DevEnv System Environment Ready!"
