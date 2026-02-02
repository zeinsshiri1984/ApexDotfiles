#!/bin/bash
set -eo pipefail
# -u: 变量未定义则报错,一旦后续加参数解析（--dry-run / --yes），-u 会频繁误杀,不利于阶段化执行
# -o pipefail: 管道中任意命令失败则整体失败

# === 常量 ===
REPO="zeinsshiri1984/ApexDotfiles"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
CHEZMOI_SRC="$XDG_DATA_HOME/chezmoi"

# === 函数 ===
log() { printf '\033[1;32m[bootstrap]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[bootstrap]\033[0m %s\n' "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

# === 前置检查 ===
has apt-get || err "仅支持 Debian/Ubuntu 系统"
has sudo    || err "需要 sudo 权限"

# === 阶段 1: XDG 目录 ===
log "确保 XDG 目录..."
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$HOME/.local/bin"

# === 阶段 2: 系统依赖 (幂等) ===
log "安装系统依赖..."
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential ca-certificates curl file git

# === 阶段 3: Linuxbrew ===
if ! has brew; then
  log "安装 Linuxbrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || err "Linuxbrew 安装失败"
fi

# 加载 brew 环境 (仅本脚本内生效)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi
has brew || err "Linuxbrew 加载失败"

# === 阶段 4: 启动级工具 ===
log "安装启动级工具..."
for pkg in chezmoi just gh mise nushell; do
  has "$pkg" || brew install --quiet "$pkg"
done

# === 阶段 5: Dotfiles ===
log "初始化 dotfiles..."

# 收集 Git 用户信息 (避免交互式提示)
CHEZMOI_ARGS=()
git_name="$(git config --global user.name 2>/dev/null || true)"
git_email="$(git config --global user.email 2>/dev/null || true)"
[ -n "$git_name" ]  && CHEZMOI_ARGS+=(--promptString "name=$git_name")
[ -n "$git_email" ] && CHEZMOI_ARGS+=(--promptString "email=$git_email")

# chezmoi init: 克隆到标准位置并应用
if [ -d "$CHEZMOI_SRC/.git" ]; then
  log "dotfiles 已存在，更新并应用..."
  chezmoi update --apply
else
  log "首次初始化 dotfiles..."
  chezmoi init "$REPO" --apply "${CHEZMOI_ARGS[@]}"
fi

# === 阶段 6: 用户工具链 ===
JUSTFILE="$XDG_CONFIG_HOME/just/justfile"
if [ -f "$JUSTFILE" ]; then
  log "运行 just setup..."
  just --justfile "$JUSTFILE" setup
fi

log "Bootstrap 完成！重新登录或执行: exec bash -l"
