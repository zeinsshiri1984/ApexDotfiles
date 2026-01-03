#!/bin/bash
set -e # 遇到错误立即停止

# --- 0. 辅助函数 ---
log() { echo -e "\033[1;32m👉 $1\033[0m"; }
warn() { echo -e "\033[1;33m⚠️ $1\033[0m"; }

log "[1/4] 检测并准备基础依赖..."

# 根据发行版安装 build-essential/git/curl
if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y build-essential curl file git procps
elif command -v dnf &> /dev/null; then
    sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y curl file git libxcrypt-compat procps-ng
elif command -v pacman &> /dev/null; then
    sudo pacman -Syu --noconfirm base-devel curl git
elif command -v rpm-ostree &> /dev/null; then
    # Bluefin 等不可变系统通常已预装 git 和容器环境
    log "检测到不可变系统 (Immutable OS)。假设基础开发库已就绪。"
    warn "如果后续 Brew 编译报错，请尝试: rpm-ostree install build-essential 并重启。"
else
    warn "未知的系统类型，尝试直接继续..."
fi

# --- 1. 安装 Homebrew ---
if [ ! -d "/home/linuxbrew/.linuxbrew" ]; then
    log "[2/4] 安装 Linuxbrew (非交互模式)..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    log "Linuxbrew 已安装，跳过。"
fi

# 临时加载 brew 到当前环境 (确保后续命令可用)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# --- 2. 安装核心工具链 ---
log "[3/4] 通过 Homebrew 安装核心工具..."
# gcc: 编译某些包的必须依赖
# gh: GitHub 认证
# chezmoi: 配置文件管理
# age: 密钥生成
# sops: 密钥加密管理
brew install gcc gh git chezmoi age sops

# --- 3. Docker 环境处理 (可选优化) ---
# 既然系统是月更且只读，建议优先使用系统自带的 Docker/Podman
# 如果系统没有，才尝试安装
if ! command -v docker &> /dev/null && ! command -v podman &> /dev/null; then
   log "检测到无容器引擎，正在安装 Docker..."
   curl -fsSL https://get.docker.com | sh
   sudo usermod -aG docker $USER
   warn "Docker 已安装。请注意：你需要重新登录或运行 'newgrp docker' 才能免 sudo 使用 docker。"
fi

log "✅ [4/4] 系统 Bootstrap 完成！"
echo "   请执行以下命令进行下一步："
echo "   gh auth login"