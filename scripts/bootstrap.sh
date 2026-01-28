#!/bin/bash
set -eou pipefail 
# -u: 变量未定义则报错
# -o pipefail: 管道中任意命令失败则整体失败

# XDG Layout (规范化目录)
echo "📂 XDG Standard Setup..."
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_BIN_HOME="$HOME/.local/bin"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" \
         "$XDG_BIN_HOME" "$XDG_DATA_HOME/bash"
         
# Host OS Dependencies,仅安装 Brew 和 Mise 编译所需的最小依赖
if command -v apt-get >/dev/null; then
    echo ">>> [Apt] Installing build essentials..."
    sudo apt-get update -qq
    # 很多 repo 需要 git-lfs
    sudo apt-get install -y -qq build-essential curl file git procps unzip git-lfs
else
    echo "Error: apt-get not found."
    exit 1
fi

# Linuxbrew (Package Manager)
if ! command -v brew >/dev/null; then
    echo ">>> [Brew] Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 临时加载环境以供脚本后续使用
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
else
    echo ">>> [Brew] Already installed."
fi

# Infrastructure Tools
echo ">>> [Infra] Installing First-Class Citizens via Brew..."
brew install \
    gcc \
    mise \
    chezmoi \
    just \
    nushell \
    gh \
    git-lfs

# Checking GitHub connectivity..."
check_ssh() {
    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
}

if check_ssh; then
    echo "✅ SSH is already configured."
else
    echo "⚠️  SSH not detected or keys not loaded."
    
    # 如果是交互式环境，调用 gh 进行登录
    if [ -t 0 ]; then
        echo "🔐 Initiating GitHub CLI Authentication..."
        echo "   (Select 'SSH' as preferred protocol when prompted)"
        
        # 登录并自动配置 git/ssh
        gh auth login -p ssh -w
        
        # 再次检查
        if ! check_ssh; then
             echo "❌ Auth failed. Please check your network or credentials."
             exit 1
        fi
    else
        echo "❌ Non-interactive shell and no SSH keys found. Cannot proceed."
        echo "   Please mount SSH keys or run interactively."
        exit 1
    fi
fi
gh auth setup-git # Configure git to use gh as credential helper

# Dotfiles Init (Chezmoi)
REPO_URL="git@github.com:zeinsshiri1984/ApexDotfiles.git"
DOTFILES_DIR="$XDG_DATA_HOME/chezmoi"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning Dotfiles..."
    chezmoi init --apply --depth=1 "$REPO_URL"
else
    echo "Updating Dotfiles..."
    # 强制重置以防本地修改冲突 (我们在 Bootstrap 阶段假设是 reset)
    # Check if directory is safe
    if [ -d "$DOTFILES_DIR/.git" ]; then
        chezmoi git -- fetch
        chezmoi git -- reset --hard origin/main
        chezmoi apply --force
    else
        echo "Corrupt dotfiles detected. Re-initializing..."
        rm -rf "$DOTFILES_DIR"
        chezmoi init --apply --depth=1 "$REPO_URL"
    fi
fi

echo "👉 Action Required: Run 'just setup' to install apps."