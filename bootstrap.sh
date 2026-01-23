#!/bin/bash
set -eou pipefail 
# -u: 变量未定义则报错
# -o pipefail: 管道中任意命令失败则整体失败

echo "🚀 Apex DevEnv Bootstrap Starting..."
# --- 0. XDG Standard Setup ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$HOME/.local/bin"

# 将 mise shims 和 local bin 加入 PATH，确保脚本后续可用
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# --- 1. Environment Detection ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    OS_ID="unknown"
fi

IS_IMMUTABLE=0
WSL_FLAG=0

if [ -f /run/ostree-booted ] || [ -f /etc/fedora-backward-compatibility ]; then
    echo "❄️  Immutable OS detected ($OS_ID). Read-only root assumed."
    IS_IMMUTABLE=1
fi

if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME-}" ]; then
    echo "🪟 WSL detected."
    WSL_FLAG=1
    
    # Check Systemd (Crucial for Nix/Devbox)
    if ! pidof systemd >/dev/null && ! pidof init | grep -q systemd; then
        if [ "$PID" != "1" ]; then
             # Simple check for systemd as PID 1
             echo "Systemd might not be running. Nix requires Systemd."
             echo "Ensure /etc/wsl.conf contains [boot] systemd=true and restart WSL."
        fi
    fi
fi

# --- 2. Base Dependencies (Standard OS Only) ---
if [ "$IS_IMMUTABLE" -eq 0 ]; then
    echo "🔧 Checking base dependencies..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git curl unzip build-essential
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git curl unzip @development-tools
    fi
fi

# --- 3. Install Mise (The Static Binary Manager) ---
if ! command -v mise &> /dev/null; then
    echo "📦 Installing Mise..."
    curl https://mise.run | sh
    # Ensure shim is active for this script execution
    eval "$($HOME/.local/bin/mise activate bash)"
else
    echo "✅ Mise detected."
    eval "$(mise activate bash)"
fi

# --- 4. Toolchain Bootstrap (Just, Chezmoi, GH) ---
echo "📦 Bootstrapping core tools via Mise..."
mise use -g -y chezmoi just github-cli

# --- 5. GitHub Authentication (Critical for Dotfiles) ---
# 只有未登录时才尝试登录
if ! gh auth status &>/dev/null; then
    echo "🔑 GitHub Auth Required for Dotfiles."
    
    echo "Login with a web browser' 并生成新的 SSH key。"
    gh auth login -p ssh -w

    # Configure git to use gh as credential helper
    gh auth setup-git
else
    echo "GitHub authenticated."
fi

# --- 6. Dotfiles Init (Chezmoi) ---
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

# --- 7. Devbox Installation (Requires Nix) ---
if ! command -v devbox &> /dev/null; then
    echo "📦 Installing Devbox (and Nix if missing)..."
    if [ "$IS_IMMUTABLE" -eq 1 ]; then
        # Immutable OS: 强制安装到用户目录，无需 sudo
        curl -fsSL https://get.jetify.com/devbox | FORCE=1 INSTALL_DIR="$HOME/.local/bin" bash
    else
        # Standard OS: 标准安装 (可能触发 sudo)
        curl -fsSL https://get.jetify.com/devbox | bash
    fi
fi

# --- 8. Finalize ---
echo "✅ Bootstrap Complete."
echo "👉 Action Required: Run 'exec bash' or restart your terminal to reload environment."
