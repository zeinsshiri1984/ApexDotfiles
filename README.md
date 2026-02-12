<div align="center">
  <a href="./README.md">English</a> | 
  <a href="./README.zh-CN.md">简体中文</a> |
  <a href="./README.ja.md">日本語</a> |
  <a href="./README.ko.md">한국어</a> |
</div>

# ApexDotfiles
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)

1) 一套追求效率与简洁的开发环境配置。
2) 面向debian系(wsl-Ubuntu,Pop_os在我机器上实测没问题)。

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

## Installation(无代理环境链接增加https://ghfast.top/ 前缀)
1.执行 bootstrap_host.sh
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeinsshiri1984/ApexDotfiles/main/scripts/bootstrap_host.sh)"
```

2.执行 bootstrap_user.sh
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeinsshiri1984/ApexDotfiles/main/scripts/bootstrap_user.sh)"
```

3.执行用户cli安装
```bash
just brew
just gh
just mise
```
## Acknowledgements
- [Awesome Readme Templates](https://awesomeopensource.com/project/elangosundar/awesome-README-templates)
- [Awesome README](https://github.com/matiassingers/awesome-readme)
- [How to write a Good readme](https://bulldogjob.com/news/449-how-to-write-a-good-readme-for-your-github-project)
- [readme generator](https://readme.so)
- [License choice](https://choosealicense.com/)
- [shields.io](https://shields.io/)
- [screen](https://www.freeconvert.com/video-compressor)