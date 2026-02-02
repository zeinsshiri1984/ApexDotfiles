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
STATE_DIR="$XDG_STATE_HOME/apex"
STATE_FILE="$STATE_DIR/bootstrap.state"

mkdir -p "$STATE_DIR"
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" != "done" ]; then
  printf '[bootstrap] 检测到未完成阶段: %s\n' "$(cat "$STATE_FILE")"
fi
trap 'stage="unknown"; [ -f "$STATE_FILE" ] && stage="$(cat "$STATE_FILE")"; printf "[bootstrap] 失败 (stage=%s)\n" "$stage" >&2' ERR

# === 阶段 1: XDG 目录 ===
printf '[bootstrap] 确保 XDG 目录...\n'
printf "xdg\n" > "$STATE_FILE"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME" "$HOME/.local/bin"

# === 阶段 2: 系统依赖 (幂等) ===
printf '[bootstrap] 安装系统依赖...\n'
printf "apt\n" > "$STATE_FILE"
command -v apt-get >/dev/null 2>&1 || { printf '[bootstrap] 仅支持 Debian/Ubuntu 系统\n' >&2; exit 1; }
command -v sudo >/dev/null 2>&1 || { printf '[bootstrap] 需要 sudo 权限\n' >&2; exit 1; }
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential ca-certificates curl file git

# === 阶段 3: Linuxbrew ===
printf '[bootstrap] 初始化 Linuxbrew...\n'
printf "brew\n" > "$STATE_FILE"
if ! command -v brew >/dev/null 2>&1; then
  printf '[bootstrap] 安装 Linuxbrew...\n'
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || { printf '[bootstrap] Linuxbrew 安装失败\n' >&2; exit 1; }
fi

# 加载 brew 环境 (仅本脚本内生效)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi
command -v brew >/dev/null 2>&1 || { printf '[bootstrap] Linuxbrew 加载失败\n' >&2; exit 1; }

# === 阶段 4: 启动级工具 ===
printf '[bootstrap] 安装启动级工具...\n'
printf "core-tools\n" > "$STATE_FILE"
for pkg in chezmoi just gh mise nushell; do
  command -v "$pkg" >/dev/null 2>&1 || brew install --quiet "$pkg"
done

# === 阶段 5: Dotfiles ===
printf '[bootstrap] 初始化 dotfiles...\n'
printf "dotfiles\n" > "$STATE_FILE"

# 收集 Git 用户信息 (避免交互式提示)
CHEZMOI_ARGS=()
git_name="$(git config --global user.name 2>/dev/null || true)"
git_email="$(git config --global user.email 2>/dev/null || true)"
[ -n "$git_name" ]  && CHEZMOI_ARGS+=(--promptString "name=$git_name")
[ -n "$git_email" ] && CHEZMOI_ARGS+=(--promptString "email=$git_email")

# chezmoi init: 克隆到标准位置并应用
if [ -d "$CHEZMOI_SRC/.git" ]; then
  printf '[bootstrap] dotfiles 已存在，更新并应用...\n'
  chezmoi update --apply
else
  printf '[bootstrap] 首次初始化 dotfiles...\n'
  chezmoi init "$REPO" --apply "${CHEZMOI_ARGS[@]}"
fi

# === 阶段 6: 用户工具链 ===
printf '[bootstrap] 运行 just setup...\n'
printf "just\n" > "$STATE_FILE"
JUSTFILE="$XDG_CONFIG_HOME/just/justfile"
if [ -f "$JUSTFILE" ]; then
  just --justfile "$JUSTFILE" setup
fi

printf "done\n" > "$STATE_FILE"
printf '[bootstrap] Bootstrap 完成！重新登录或执行: exec bash -l\n'
