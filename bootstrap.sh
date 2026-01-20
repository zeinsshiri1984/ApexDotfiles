#!/bin/bash
set -euo pipefail

echo "🚀环境初始化..."
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export PATH="$HOME/.local/bin:$PATH"

OS_ID="$(awk -F= '/^ID=/{print $2}' /etc/os-release 2>/dev/null | tr -d '"')"
WSL_FLAG=0
if grep -qi microsoft /proc/version 2>/dev/null; then
    WSL_FLAG=1
fi
GUI_FLAG=0
if [ -n "${DISPLAY-}" ] || [ "${XDG_SESSION_TYPE-}" = "wayland" ] || [ "${XDG_SESSION_TYPE-}" = "x11" ]; then
    GUI_FLAG=1
fi

ROOT_MOUNT_OPTS="$(findmnt -no OPTIONS / 2>/dev/null || true)"
if echo "$ROOT_MOUNT_OPTS" | grep -qE '(^|,)ro(,|$)'; then
    echo "✅ 根分区处于只读模式"
else
    echo "⚠️  根分区为可写，请确保不可变系统策略已启用"
fi

if ! command -v mise &> /dev/null; then
    echo "📦安装mise"
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
    chezmoi apply --keep-going #--keep-going 防止因单个文件冲突导致整个更新停止
fi

echo "📦mise install"
mise install

echo "🎉 系统已就绪。请将终端启动命令设为 'nu'。"
