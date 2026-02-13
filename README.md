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

# 环境方案
## 最小化系统环境:
1) Host OS随时可丢弃；仅作为Linux 内核 + 用户态容器宿主;脚本仅部署启动级/逃生级工具
2) rootless podman优先,兼容docker命令和docker compose脚本
3) 虽然不是真正的immutable os, 但baes os尽量自律式不可写

## 可快速恢复的用户态环境:
1) 用户态包管理器规避FHS路径造成的依赖冲突: 使用Linuxbrew管理cli工具,flatpak管理GUI工具,mise管理开发工具链;所有工具都是声明式管理的,一条命令快速部署/恢复
2) 脚本shell bash + 交互shell nushell: `~/.profile` 为环境事实源; bash作为默认登录shell; 由交互式bash启动nushell, 达成了两shell共用一套环境的目的
3) 遵循XDG规范
4) 开箱即用的zellij + yazi + helix + lazygit + podman-tui + btop + claude code基础开发环境
5) 交互增加: starship + Carapace-bin
6) ~/just/下编写了大量日常维护命令

## 工具链和依赖可复现的项目环境
1) 不依赖FHS硬编码动态包:mise实现工具链复现及路径隔离(不同路径生效不同runtime / toolchain)+语言原生包管理器实现依赖复现
2) 依赖FHS硬编码动态包:mise实现工具链复现及路径隔离(不同路径生效不同runtime / toolchain)+distrobox实现FHS硬编码动态包依赖复现+语言原生包管理器实现非FHS包复现

# Screenshots
<div align="center">
  <video src="" width="100%" autoplay loop muted playsinline controls></video>
</div>

# Installation(无代理环境,可在链接前添加https://ghfast.top/ 前缀)
1.执行 bootstrap_host.sh
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeinsshiri1984/ApexDotfiles/main/scripts/bootstrap_host.sh)"
```

2.执行 bootstrap_user.sh
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeinsshiri1984/ApexDotfiles/main/scripts/bootstrap_user.sh)"
```

执行完这步后要重启登录shell使配置生效, 不清楚就重启发行版

3.执行用户cli安装
```bash
just brew
just gh
just mise
```
# Acknowledgements
- [Awesome Readme Templates](https://awesomeopensource.com/project/elangosundar/awesome-README-templates)
- [Awesome README](https://github.com/matiassingers/awesome-readme)
- [How to write a Good readme](https://bulldogjob.com/news/449-how-to-write-a-good-readme-for-your-github-project)
- [readme generator](https://readme.so)
- [License choice](https://choosealicense.com/)
- [shields.io](https://shields.io/)
- [screen](https://www.freeconvert.com/video-compressor)
