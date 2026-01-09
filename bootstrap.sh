#!/bin/bash
set -e # 遇到错误立即停止

echo "🚀 [1/5] 基础环境检测"
if [ -f /run/ostree-booted ]; then
    echo "🛡️ 检测到不可变系统 (Silverblue/Bluefin)，跳过 apt/dnf 安装。"
else
    # 常规系统：确保 build-essential 存在，否则 Homebrew 编译源码会挂
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y build-essential curl file git procps
    elif command -v dnf &>/dev/null; then
        sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y curl file git procps-ng
    fi
fi

echo "🍺 [2/5] Homebrew 状态检查..."
if ! command -v brew &>/dev/null; then
    export NONINTERACTIVE=1
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# 临时加载环境以供脚本后续使用
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "📦 [3/5]安装 Chezmoi & GitHub CLI..."
brew install gcc git gh chezmoi

echo "🐳 [4/5] GitHub 认证..."
if ! gh auth status &>/dev/null; then
    # -p ssh: 强制使用 SSH 协议;-w: 使用 Web 浏览器登录;--git-protocol ssh: 确保后续 git clone 操作默认用 git@github.com
    gh auth login -p ssh -w --git-protocol ssh
    
    if [ $? -ne 0 ]; then
        echo "❌ 登录失败或被取消，脚本终止。"
        exit 1
    fi
else
    echo "GitHub 已认证"
fi

echo "配置 Copilot CLI..."
gh extension install github/gh-copilot --force &>/dev/null || gh extension upgrade github/gh-copilot &>/dev/null || true

echo "⚡️ [5/5]拉取Dotfiles并应用配置..."
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    chezmoi init --apply ApexDotfiles
else
    # 加上 --keep-going 防止因单个文件冲突导致整个更新停止
    chezmoi apply --keep-going
fi

echo "🎉 系统就绪！请重启终端。"