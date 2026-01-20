## 总体原则
- XDG 规范化：所有配置写入 $XDG_CONFIG_HOME 等路径，零散文件收敛到 Chezmoi
- 声明式与幂等：bootstrap.sh 仅执行用户态安装与配置；多次运行无副作用
- 终端优先：Zellij + Helix 为主；AI 辅助；容器化开发优先 rootless Podman
- 视觉统一：Noctis 全栈主题（Shell/Editor/Multiplexer）；极简、低噪声
- 三场景兼容：Bluefin-DX（只读根，Flatpak/Distrobox）、Pop_OS/Fedora（GUI 常规）、WSL Headless（纯终端）

## 阶段 1：系统环境（子步骤执行后逐步确认）
### 1.1 bootstrap.sh 设计与自律
- 检测 OS：Bluefin/Pop_OS/Fedora/WSL（读 /etc/os-release 与环境特征）
- Bluefin-DX：仅用户态安装（Flatpak/Distrobox/Mise/Devbox）；绝不改动只读根
- Pop_OS/Fedora：优先用户态（Mise/Devbox），必要依赖使用包管理；Podman rootless
- WSL Headless：用户态安装；跳过 GUI 步骤；Podman rootless/兼容 docker-compose
- 幂等：每步带“已安装则跳过”逻辑；显式日志与错误收敛

### 1.2 Shell 编排
- Login Shell = Bash；终端启动命令设为 nu（Nushell+Atuin+fzf+Carapace+Starship）
- 保持 zsh 仅临时交互，避免与 nu 配置冲突（路径与补全隔离）
- XDG 导出与路径统一（历史、缓存、临时文件）

### 1.3 基础工具栈安装（用户态）
- Zellij, Superfile, Helix, Lazygit, Yazi, Podman-tui：优先通过 Mise/Devbox；Bluefin 用 Flatpak/Distrobox 作为后备
- Rootless Podman：启用无特权运行；WSL/GUI 分支化处理（systemd/uidmap 检查与修复）

## 阶段 2：多任务并行开发环境
### 2.1 Zellij 标准布局
- 布局：Coding | Test | Debug | Research | Ops（~/.config/zellij/layouts/*.kdl）
- Pane 绑定：左 Helix（主工作区），右 Terminal（AI 交互），浮动：Superfile(Ctrl+f)/Lazygit(Ctrl+g)/Podman-tui(Ctrl+p)

### 2.2 Pane 管理策略
- Zellij 键位：打开/隐藏浮动面板；焦点切换；会话保存与恢复
- FM 策略：普通终端用 Yazi；Zellij 内用 Superfile（避免预览冲突）

### 2.3 编辑器与 LSP-AI
- Helix：启用语言服务器；增加 Noctis 主题（~/.config/helix/themes/noctis.toml），保持现有配置
- LSP-AI：通过外部命令桥接（pipe 选区到 AI CLI；返回写入 buffer/新窗格）

### 2.4 Lazygit/Podman-tui 原生命令可视化
- Lazygit：开启命令日志面板、记录执行的 git 原生命令
- Podman-tui：启用详细模式/命令回显（若工具支持），否则旁路日志捕获

## 阶段 3：AI-First CLI 集成
### 3.1 安装与配置
- 工具：Mods、Fabric、Claude Code、Aider、CC-switch（均用户态安装；WSL 跳过 GUI 依赖）
- 统一入口：~/.local/bin 提供可执行封装，兼容 Zellij/Nushell

### 3.2 Nushell/Zellij 快捷键
- AI Ask：读取选区/输入 → mods+fabric → 输出到 Stdout（右 Pane）
- AI Complete：当前命令行 → mods+System Prompt（补全部分）→ 追加/替换
- AI Fix：读取上一条命令错误 → mods 生成修复命令 → 放入 Buffer 等待确认执行

### 3.3 API Keys 管理
- Mise 任务 + Bitwarden CLI：会话登录后按需拉取密钥，注入临时环境变量
- 秘钥仅驻留会话内存；绝不落盘；统一前缀（如 AI_*）避免泄漏

## 阶段 4：维护操作收敛
- 全局 justfile：run/update/clean/sync 一键集合
- 改变 Shell 状态的高频命令写成 Shell Function（cd/export 等）；just 仅调用函数

## 阶段 5：UI/UX & 通知
### 5.1 Noctis 全栈主题
- Shell（Starship）、Helix、Zellij 统一 Noctis 调色；优先 Obscuro/Uva/Lux 变体按背景环境选择
- Helix 主题移植：将 Noctis 标准色映射到语法组（字符串、注释、关键字等）

### 5.2 通知与声音
- ntfy.sh：任务完成/AI 响应推送；Bluefin/GUI 走系统通知；WSL 走 CLI 文本提示
- 声音提示：GUI 用 canberra/paplay；WSL 退化到终端“铃声/文本”

### 5.3 语音输入
- Whisper-Typist：终端热键启动、结果注入当前 Pane；WSL 跳过麦克风链路或走离线模式

### 5.4 Starship 丰富信息
- Starship 仿 p10k 信息密度；此步将索取您的 p10k 配置以映射段落与图标

## 阶段 6：工具适配与一致性
- Mise/Devbox 全局工具逐一适配：补全、缓存、日志、代理、并发与资源限额
- 冲突检测：Yazi 与 Superfile 预览；zsh/nu 补全；容器网络端口占用
- 性能优化：按场景调整并发与缓存；WSL 限制 I/O；Bluefin 强制用户态路径

## 项目环境（模板化与可回滚）
### 7.1 模板与管理
- ts/go/java/rust：mise+Lefthook+gitleaks（可静态打包依赖）
- python/c/cpp/zig：Devbox+mise+ujust+Lefthook+gitleaks+copier（FHS/LGPL 动态库与 ABI）
- Distrobox：管理需改动 base OS 驱动的项目

### 7.2 Chezmoi 管理与忽略
- 在 Chezmoi 目录放模板；.chezmoiignore 仅生成项目文件夹占位，不展开到 ~
- 所有操作收敛到项目级 justfile；依赖锁定、手动更新、可回滚

## 交付物（按子步骤实施）
- bootstrap.sh（幂等、三场景分支）
- XDG 导出与 Shell 初始化文件（Bash/Nushell/zsh 隔离）
- Zellij 布局与键位配置；Helix 主题与 LSP；Starship 配置骨架
- Lazygit/Podman-tui 显示命令配置；AI CLI 封装与键位桥接
- 全局 justfile；Mise/Devbox 全局配置；Bitwarden 拉取任务
- 项目模板（ts/go/java/rust、python/c/cpp/zig）与回滚策略

——
将按上述顺序逐子步骤落地，每完成一子步骤即暂停等待您的确认后继续下一步。请确认整体方案或指出需微调的部分。