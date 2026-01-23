#!/bin/bash
set -e  # 遇到错误立即退出，但不使用 -u (nounset) 避免某些环境变为空导致的崩溃

echo "🚀 Apex DevEnv Bootstrap Starting..."
# --- 0. XDG Standard Setup ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
# 强制将 mise shims 和 local bin 加入 PATH，确保脚本后续可用
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$HOME/.local/bin"

# --- 1. Environment Detection ---
OS_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
IS_IMMUTABLE=0
WSL_FLAG=0

if [ -f /run/ostree-booted ] || [ -f /etc/fedora-backward-compatibility ]; then
    echo "❄️  Immutable OS detected ($OS_ID). Skipping system package Install."
    IS_IMMUTABLE=1
fi

if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME-}" ]; then
    echo "🪟 WSL detected."
    WSL_FLAG=1
fi

# --- 2. Base Dependencies (Standard OS Only) ---
# Immutable OS 必须确保 Base Image 已经包含了 git, curl, unzip
if [ "$IS_IMMUTABLE" -eq 0 ]; then
    echo "🔧 Checking base dependencies..."
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu/WSL
        if ! command -v git &> /dev/null || ! command -v curl &> /dev/null || ! command -v unzip &> /dev/null; then
             echo "📦 Installing base utils (sudo required)..."
             sudo apt-get update && sudo apt-get install -y git curl unzip build-essential
        fi
    elif command -v dnf &> /dev/null; then
        # Fedora/CentOS
         if ! command -v git &> /dev/null || ! command -v curl &> /dev/null; then
             sudo dnf install -y git curl unzip @development-tools
         fi
    fi
fi

# --- 3. Install Mise (The Static Binary Manager) ---
if ! command -v mise &> /dev/null; then
    echo "📦 Installing Mise..."
    curl https://mise.run | sh
    # 立即在当前 shell 会话中激活 mise
    eval "$($HOME/.local/bin/mise activate bash)"
else
    echo "✅ Mise already installed."
    eval "$(mise activate bash)"
fi

# --- 4. Toolchain Bootstrap (Just, Chezmoi, GH) ---
# 我们先通过 mise 安装这三个核心工具，以便后续操作
echo "📦 Bootstrapping core tools via Mise..."
mise use -g -y chezmoi just github-cli

# --- 5. GitHub Authentication (Critical for Dotfiles) ---
# 只有未登录时才尝试登录
if ! gh auth status &>/dev/null; then
    echo "🔑 GitHub Auth Required."
    echo "👉 注意：如果不使用 SSH Agent Forwarding，建议选择 'Login with a web browser' 并生成新的 SSH key。"
    if [ "$WSL_FLAG" -eq 1 ]; then
        # WSL 环境下 web flow 也是可行的（会调用宿主机浏览器）
        gh auth login -p ssh -w
    else
        gh auth login -p ssh -w
    fi
    # 自动配置 git 协议使用 gh 提供的 token/key
    gh auth setup-git
fi

# --- 6. Dotfiles Init (Chezmoi) ---
REPO_URL="git@github.com:zeinsshiri1984/ApexDotfiles.git"
DOTFILES_DIR="$XDG_DATA_HOME/chezmoi"

# 如果目录存在但不是 git 仓库（比如是个空壳），暴力清理
if [ -d "$DOTFILES_DIR" ] && [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "🧹 Detected corrupt dotfiles directory. Cleaning up..."
    rm -rf "$DOTFILES_DIR"
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "⬇️  Cloning Dotfiles..."
    # 尝试 SSH clone，如果因为 Key 问题失败，提示用户
    if ! chezmoi init --apply "$REPO_URL"; then
        echo "❌ SSH Clone failed. attempting to fix or fallback."
        echo "⚠️  Ensure you have added your SSH key to GitHub or used 'gh auth login' to upload one."
        exit 1
    fi
else
    echo "🔄 Updating Dotfiles..."
    chezmoi apply --force
fi

# --- 7. Devbox Installation (Requires Nix) ---
if ! command -v devbox &> /dev/null; then
    echo "📦 Installing Devbox..."
    # Devbox 安装脚本会自动处理 Nix 安装 (如果不存在)
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
