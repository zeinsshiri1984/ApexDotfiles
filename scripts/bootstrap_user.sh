#!/bin/bash
set -eo pipefail
# -o pipefail: 管道中任意命令失败则整体失败
# 不使用 -u: 避免参数解析时未定义变量报错

echo "确立xdg规范"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.local/state"
mkdir -p "$HOME/.cache"
mkdir -p "$HOME/.local/bin"
sudo nala install -y xdg-user-dirs
xdg-user-dirs-update
xdg-user-dirs-update --force

echo "部署linuxbrew"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "brew环境变量对当前shell环境立即生效"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -d ~/.linuxbrew && eval "$(/~/.linuxbrew/bin/brew shellenv)"

# === 阶段 5: 启动级工具 ===
printf '[bootstrap] [5/7] 安装启动级工具...\n'
printf "core-tools\n" > "$STATE_FILE"
for pkg in chezmoi just gh mise nushell; do
  if command -v "$pkg" >/dev/null 2>&1; then
    printf '[bootstrap] %s: 已安装\n' "$pkg"
  else
    printf '[bootstrap] 安装 %s...\n' "$pkg"
    brew install --quiet "$pkg"
  fi
done
printf '[bootstrap] [5/7] 完成\n'

# === 阶段 6: Dotfiles ===
printf '[bootstrap] [6/7] 初始化 dotfiles...\n'
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
printf '[bootstrap] [6/7] 完成\n'

# === 阶段 7: 用户工具链 ===
printf '[bootstrap] [7/7] 运行 just setup...\n'
printf "just\n" > "$STATE_FILE"
JUSTFILE="$XDG_CONFIG_HOME/just/justfile"
if [ -f "$JUSTFILE" ]; then
  just --justfile "$JUSTFILE" setup
else
  printf '[bootstrap] justfile 未找到，跳过 setup\n'
fi

printf "done\n" > "$STATE_FILE"
printf '[bootstrap] ✓ Bootstrap 完成！重新登录或执行: exec bash -l\n'
