#!/bin/bash
set -eo pipefail
# -o pipefail: 管道中任意命令失败则整体失败

echo "确立xdg规范"
mkdir -p "$HOME/.config" \
         "$HOME/.local/share" \
         "$HOME/.local/state" \
         "$HOME/.cache" \
         "$HOME/.local/bin"
xdg-user-dirs-update --force

echo "部署linuxbrew"
export NONINTERACTIVE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "brew环境变量对当前shell环境立即生效"
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

echo "安装用户环境基础工具"
brew install chezmoi just

echo "拉取用户配置"
chezmoi init --apply --force https://github.com/zeinsshiri1984/ApexDotfiles

echo "用户环境预部署完成！后续执行just gh,just brew,just mise完全部署"
echo " chezmoi原生命令:"
echo "- 同步远程最新更改: chezmoi update -v"
echo "- 手动重新应用配置: chezmoi apply"
echo "- 查看本地差异:     chezmoi diff"
echo "- 进入源码目录:     chezmoi cd"
echo " brew原生命令:"
echo "  更新仓库：brew update"
echo "  升级软件：brew upgrade"
echo "  查看已装：brew list"