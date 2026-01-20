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

The world's top-level development environment configuration

1) Compliant with xdg path standards
2) Decoupling of system environment, user environment, and project environment
3) Immutable system environment: base OS is immutable (using an immutable operating system or self-regulating mechanisms for assurance)
4) Rolling update user environment: Linuxbrew + Chezmoi
5) Reproducible project environment: Devbox + direnv + Just Lefthook + gitleaks + copier; enter the specific project directory to load the corresponding environment; Chezmoi will manage the common template configuration for project types
6) Deploy with one-click operation by simply running bootstrap.sh!
7) Defined advanced AI workflow: using zellij session for multi-project parallel development; zellij tab for multi-agent parallel development; zellij pane distinguishes the editing area and the terminal interaction area; yazi as the file tree of helix
8) Zsh shell configuration with top-notch performance and user experience, ready to use out of the box!

## Screenshots

<div align="center">
  <video src="" width="100%" autoplay loop muted playsinline controls></video>
</div>

## Installation

Execute the following command to deploy the world's first development environment in one click.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zeinsshiri1984/ApexDotfiles/main/bootstrap.sh)"
```
    
## Roadmap

 - Yazi配置优化
 - helix配置优化
 - tokie配置
 - 验证交互工具配置是否生效
 - zellij配置优化
 - 项目模板补全
 - 尝试用github action自动翻译多语言版本readme
 - read描写ai工作流
 - ai工作流:review ,ask ,fix ,explain,commit时自动生成commit内容,自动commit保存ai工作版本?,agent,skill,mcp,rag
 长停顿触发基于本地模型的ai幽灵补全建议;
 4)终端生成命令到stdout;explain/fix上文报错功能:zsh-ai-cmd

<!-- 0)Antidote + zsh-defer+z-shell/F-Sy-H+p10k配置 -->
<!-- 1)历史管理:Atuin启用 Sync 功能,Atuin 负责在后台将多端同步的历史数据实时导出/同步到本地的 standard zsh history 文件中;Up 键：不被 Atuin 劫持。继续使用 Zsh 原生的 history-substring-search 或基础 Up，读取的是由 Atuin 喂饱的 Zsh 内存堆栈;Ctrl+R绑定 Atuin 的全屏搜索界面 -->
<!-- 2)弹出补全:fzf + Atuin + (Zsh Built-ins + Carapace)+fzf-tab(禁止预览,用原生UI,与终端视觉统一);Zsh 原生补全负责底层（文件路径、SCP 远程主机、PID 等），Carapace 负责应用层（Docker, K8s, AWS, Git 等现代 CLI）。Carapace 设为 Fallback 或特定注入，二者共存;Atuin提供历史补全数据 -->
<!-- 3)幽灵补全:zsh-autosuggestions+优先显示Atuin注入的历史记录，如果没有，则尝试调用(Carapace+Zsh Built-ins)的补全建议 -->
4)快捷键触发,读取当前你输入的内容，发送给 AI，然后用 AI 的返回结果替换或追加到当前命令行:mods+System Prompt+ZLE Widget约束使其返回命令
5)快捷键触发explain/fix上文报错功能,获取上一条命令的文本,生成修复建议放入 Buffer:mods+System Prompt+ZLE Widget约束使其返回命令
6)终端ask功能,读取当前你输入的内容发给ai:mods+Fabric+对话模型
7)编程主力cli
1.预置claude code和codex,买了token就用官方的或用aider
2.简单任务模型用claude code+cc switch或https://github.com/anomalyco/opencode
8)拥有免费token的cli: https://github.com/google-gemini/gemini-cli+https://github.com/anomalyco/opencode
9)mise管理python,ts,go,java项目环境;devbox管理cpp,c,zig,rust项目环境

11)atuin历史记录等隐私信息加密后上传github
<!-- 12)UI一致性+护眼+极低视觉噪声+Noctis默认主题 -->
13)atuin的历史记录是否做到:空间不足删重复,忽略连续重复,删除旧重复,搜索不显示重复,保存不含重复,空格开头不记录等策略
14)podman-docker包
15)完善二进制工具挂载

10)我说ok才进行下一步,知道了就说ok





进zellij之前,即用户环境:nushell
coding:Nushell
test/run:zsh
Debug/Logs:nushell
Research:nushell
Data/Ops:nushell























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