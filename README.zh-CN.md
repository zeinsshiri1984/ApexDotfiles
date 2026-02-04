<div align="center">
  <a href="./README.md">English</a> | 
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="./README.zh-TW.md">繁體中文</a> |
  <a href="./README.ja.md">日本語</a> |
  <a href="./README.ko.md">한국어</a> |
  <a href="./README.de.md">Deutsch</a> |
  <a href="./README.fr.md">Français</a> |
  <a href="./README.es.md">Español</a> |
  <a href="./README.ru.md">Русский</a>
</div>

# ApexDotfiles

面向 WSL-Ubuntu（无 GUI）的可复现开发环境 dotfiles。

1) XDG 规范化：`~/.profile` 为环境唯一事实源  
2) 宿主最小化：仅启动级/逃生级工具  
3) 用户态可滚动更新：Linuxbrew + chezmoi  
4) 运行时分离：mise 只管 runtime + brew 不提供的 CLI  
5) Bash 只做脚本/CI/SSH glue，交互统一切换 Nushell  
6) Zellij 工作台：tab=worktree，pane=编辑/终端，Alt 前缀  
7) TUI 默认栈：helix + yazi + lazygit（Noctis 风格）  
8) 项目级可丢弃：Distrobox + just + templates  
9) AI 终端：Nushell + ShellGPT（ask/complete/fix/commit）

## Screenshots

<div align="center">
  <video src="" width="100%" autoplay loop muted playsinline controls></video>
</div>

## Installation (仅支持 Ubuntu 24.04+)

```bash
# 1. 设置 apt 清华镜像源
sudo sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources
sudo sed -i 's|http://security.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/ubuntu.sources

# 2. 执行 bootstrap (brew 镜像已内置脚本，无需预设环境变量)
bash -c "$(curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/zeinsshiri1984/ApexDotfiles/main/scripts/bootstrap.sh)"
```

## Roadmap

- 完成 README 多语言版本或移除无效链接  
- 统一项目模板入口（dbx/ai-shell/just）  
- 细化 devbox 与原生包管理的项目分类  
- bootstrap.sh 强幂等与无半配置态  
- Zellij/Yazi/Helix 快捷键与用法文档  
- AI 工作流文档化与最小测试覆盖

## Badges

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)

## FAQ

#### Homebrew download failed

In regions with restricted internet access such as China, network proxy tools are necessary.

#### Configuration of chezmoi failed to be created

If the ~/.local/share directory already contains the chezmoi directory, this will cause the failure. Make sure your machine is running the bootstrap.sh for the first time.

## Acknowledgements

- [Awesome Readme Templates](https://awesomeopensource.com/project/elangosundar/awesome-README-templates)
- [Awesome README](https://github.com/matiassingers/awesome-readme)
- [How to write a Good readme](https://bulldogjob.com/news/449-how-to-write-a-good-readme-for-your-github-project)
- [readme generator](https://readme.so)
- [License choice](https://choosealicense.com/)
- [shields.io](https://shields.io/)
- [screen](https://www.freeconvert.com/video-compressor)