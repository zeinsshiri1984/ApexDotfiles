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
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

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
    if ! pidof systemd >/dev/null && ! pidof init | grep -q systemd; then
        if [ "$PID" != "1" ]; then
             echo "⚠️  CRITICAL: Systemd not running. Podman Socket requires Systemd."
             echo "   Add '[boot] systemd=true' to /etc/wsl.conf and restart WSL."
        fi
    fi
fi

# Checking system dependencies(Standard OS Only)
if [ "$IS_IMMUTABLE" -eq 0 ]; then
echo "🔧 add system dependencies(Standard OS Only)..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y git curl unzip build-essential podman
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y -q git curl unzip @development-tools podman
    fi
else
    # [Check] Verify crucial tools exist
    for cmd in git curl podman; do
        if ! command -v $cmd &> /dev/null; then
            echo "❌ Critical Missing: $cmd. Please overlay install it or use a proper base image."
            exit 1
        fi
    done
fi

# --- Install Mise (The Static Binary Manager) ---
if ! command -v mise &> /dev/null; then
    echo "📦 Installing Mise..."
    curl https://mise.run | sh
    # Ensure shim is active for this script execution
    eval "$($HOME/.local/bin/mise activate bash)"
else
    echo "✅ Mise detected."
    eval "$(mise activate bash)"
fi

# ---  Toolchain Bootstrap (Just, Chezmoi, GH) ---
echo "📦 Bootstrapping core tools via Mise..."
mise use -g -y -q chezmoi just gh usage

echo "🐳 Configuring Container Engine..."
# 1. 激活 Podman Socket (Rootless)
if command -v systemctl &>/dev/null; then
    # 幂等性检查：只要 socket 没 active 就尝试启动
    if ! systemctl --user is-active --quiet podman.socket; then
        echo "   Starting Podman User Socket..."
        systemctl --user enable --now podman.socket
    fi
fi
# 2. 验证 Socket 路径
SOCK_PATH="$XDG_RUNTIME_DIR/podman/podman.sock"
if [ ! -S "$SOCK_PATH" ]; then
    echo "⚠️  Warning: Podman socket not found at $SOCK_PATH"
    echo "   Please check 'systemctl --user status podman.socket'"
else
    echo "   Socket Active: $SOCK_PATH"
fi
# 3. 预安装官方 Docker CLI (通过 Mise)
# 这会从 download.docker.com 获取纯净的二进制文件，不含 Docker Desktop 杂质
if ! command -v docker &>/dev/null; then
    echo "   Installing Official Docker CLI via Mise..."
    # 这里的 docker-cli 是 mise 的插件，下载官方静态二进制
    mise use -g -y docker-cli
else
    echo "   Docker CLI already present."
fi
# 4. 配置 Docker Host (Bootstrap 阶段临时生效，持久化由 .profile 接管)
export DOCKER_HOST="unix://$SOCK_PATH"
export DOCKER_SOCK="$SOCK_PATH"

# Kernel Tuning (Non-Blocking)
if [ -w /proc/sys/fs/inotify/max_user_watches ]; then
    CURRENT_LIMIT=$(cat /proc/sys/fs/inotify/max_user_watches)
    if [ "$CURRENT_LIMIT" -lt 524288 ]; then
        echo "⚠️  Low file watch limit ($CURRENT_LIMIT)."
        if command -v sudo &>/dev/null; then
             echo "🔧 Increasing limit to 524288..."
             echo 524288 | sudo tee /proc/sys/fs/inotify/max_user_watches >/dev/null
        else
             echo "   Run manually: echo 524288 | sudo tee /proc/sys/fs/inotify/max_user_watches"
        fi
    fi
fi

# ---  GitHub Authentication (Critical for Dotfiles) ---
if ! gh auth status &>/dev/null; then
    echo "🔑 GitHub Auth Required for Dotfiles."
    
    if [ -t 0 ]; then
        gh auth login -p ssh -w
        gh auth setup-git     # Configure git to use gh as credential helper
    else
        echo "❌ Non-interactive shell detected. Cannot authenticate GitHub."
    fi
else
    echo "GitHub authenticated."
fi

# ---  Dotfiles Init (Chezmoi) ---
REPO_URL="git@github.com:zeinsshiri1984/ApexDotfiles.git"
DOTFILES_DIR="$XDG_DATA_HOME/chezmoi"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning Dotfiles..."
    if ! chezmoi init --apply "$REPO_URL"; then
        echo "Chezmoi Init failed. Check your SSH keys or internet connection."
    fi
else
    echo "Updating Dotfiles..."
    # Check if directory is safe
    if [ -d "$DOTFILES_DIR/.git" ]; then
        chezmoi apply --force
    else
        echo "Corrupt dotfiles detected. Re-initializing..."
        rm -rf "$DOTFILES_DIR"
        chezmoi init --apply "$REPO_URL"
    fi
fi

# ---  Devbox Installation (Requires Nix) ---
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

echo "✅ Bootstrap Complete.👉 Run 'exec bash' to reload environment."
