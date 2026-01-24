#!/bin/bash
set -eou pipefail 
# -u: 变量未定义则报错
# -o pipefail: 管道中任意命令失败则整体失败

echo "📂 XDG Standard Setup..."
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" \
         "$HOME/.local/bin" "$XDG_DATA_HOME/bash"
         
# Add local bins to PATH for immediate script usage
export PATH="$HOME/.local/bin:$XDG_DATA_HOME/mise/shims:$XDG_DATA_HOME/mise/bin:$PATH"

echo "🔍 Detecting Environment..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    OS_ID="unknown"
fi

IS_IMMUTABLE=0
[ -f /run/ostree-booted ] && IS_IMMUTABLE=1
echo "🔍 Detected: $OS_ID (Immutable: $IS_IMMUTABLE)"

if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME-}" ]; then
    echo "🪟 WSL Detected."
    if [ "$(cat /proc/1/comm 2>/dev/null)" != "systemd" ]; then
         echo "⚠️  CRITICAL: Systemd not running. Podman Socket requires Systemd."
         echo "   Add '[boot] systemd=true' to /etc/wsl.conf and restart WSL."
    fi
fi

# Kernel Tuning (Non-Blocking)
# 仅在可写且值不足时尝试修改，减少 sudo 触发频率
if [ -w /proc/sys/fs/inotify/max_user_watches ]; then
    CURRENT_LIMIT=$(cat /proc/sys/fs/inotify/max_user_watches)
    if [ "$CURRENT_LIMIT" -lt 524288 ]; then
        echo "🔧 Performance: Increasing inotify limit..."
        sudo sysctl -w fs.inotify.max_user_watches=524288 fs.inotify.max_user_instances=512 >/dev/null 2>&1 || true
    fi
fi

# Checking system dependencies
if [ "$IS_IMMUTABLE" -eq 0 ]; then
echo "🔧 Installing system dependencies(Standard OS Only)..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y git curl unzip build-essential podman
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y -q git curl unzip @development-tools podman
    fi
else
    # Verify crucial tools exist
    for cmd in git curl podman; do
        if ! command -v $cmd &> /dev/null; then
            echo "❌ Critical Missing: $cmd. Please overlay install it or use a proper base image."
            exit 1
        fi
    done
fi

# 独立安装 Chezmoi (mise配置损坏时方便修复)
if ! command -v chezmoi &> /dev/null; then
    echo "📦 Installing Standalone Chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

# --- Install Mise (The Static Binary Manager) ---
if ! command -v mise &> /dev/null; then
    echo "📦 Installing Mise..."
    curl https://mise.run | sh
else
    echo "✅ Mise detected."
fi

# GitHub Authentication (Critical for Dotfiles and mise)
if ! command -v gh &> /dev/null; then
    mise use -g -y -q gh@latest
fi

if ! mise exec gh auth status &>/dev/null; then
    if [ -t 0 ]; then
        echo "🔑 GitHub Auth Required for Dotfiles."
        mise exec gh -- gh auth login -p ssh -w
        mise exec gh -- gh auth setup-git # Configure git to use gh as credential helper
    else
        echo "❌ Non-interactive shell detected. Cannot authenticate GitHub."
    fi
else
    echo "GitHub authenticated."
fi

# mise会读取GITHUB_TOKEN突破匿名用户60次/m的限制
if mise exec gh -- gh auth status &>/dev/null; then
    export GITHUB_TOKEN=$(mise exec gh -- gh auth token)
fi

# Toolchain Bootstrap (Just, Chezmoi, GH)
echo "📦 Bootstrapping core tools via Mise..."
mise use -g -y -q chezmoi just usage node@lts uv

echo "🐳 Configuring Container Engine..."
# 激活 Podman Socket (Rootless)
if command -v systemctl &>/dev/null; then
    if ! systemctl --user is-active --quiet podman.socket; then
        echo "   Starting Podman User Socket..."
        systemctl --user enable --now podman.socket || echo "   ⚠️ Systemd not ready."
    fi
fi
# 验证 Socket 并设置 XDG 规范变量
SOCK_PATH="$XDG_RUNTIME_DIR/podman/podman.sock"
if [ -S "$SOCK_PATH" ]; then
    echo "   Socket Active: $SOCK_PATH"
    # 配置 Docker Host (Bootstrap 阶段临时生效，持久化由 .profile 接管)
    export DOCKER_HOST="unix://$SOCK_PATH"
    export DOCKER_SOCK="$SOCK_PATH"
fi
# 安装 Docker CLI 作为 Podman 的前端
mise use -g -y docker-cli

# Dotfiles Init (Chezmoi)
REPO_URL="git@github.com:zeinsshiri1984/ApexDotfiles.git"
DOTFILES_DIR="$XDG_DATA_HOME/chezmoi"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning Dotfiles..."
    if ! mise exec chezmoi -- chezmoi init --apply "$REPO_URL"; then
        echo "Chezmoi Init failed. Check your SSH keys or internet connection."
    fi
else
    echo "Updating Dotfiles..."
    # Check if directory is safe
    if [ -d "$DOTFILES_DIR/.git" ]; then
        mise exec chezmoi -- chezmoi apply --force
    else
        echo "Corrupt dotfiles detected. Re-initializing..."
        rm -rf "$DOTFILES_DIR"
        mise exec chezmoi -- chezmoi init --apply "$REPO_URL"
    fi
fi

# Devbox Installation (Requires Nix)
if ! command -v devbox &> /dev/null; then
    echo "📦 Installing Devbox..."
    if [ "$IS_IMMUTABLE" -eq 1 ]; then
        # Immutable OS: 强制安装到用户目录，无需 sudo
        curl -fsSL https://get.jetify.com/devbox | FORCE=1 INSTALL_DIR="$HOME/.local/bin" bash
    else
        # Standard OS: 标准安装 (可能触发 sudo)
        curl -fsSL https://get.jetify.com/devbox | bash
    fi
fi

echo "✅ Bootstrap Complete.👉 Please run 'exec bash' or 'source ~/.bashrc'."
