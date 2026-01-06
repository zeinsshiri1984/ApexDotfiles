# --- 第三方源 ---
tap "xo/xo" # USQL 官方源
tap "derailed/k9s"    # K9s 官方源
tap "hashicorp/tap"   # Terraform/Vault

# --- 核心环境 ---
brew "chezmoi"
brew "git" #用户级 Git 永远不会因为权限问题去污染 /etc 或 /usr
brew "gh"
brew "just"
brew "lefthook"     # Git Hooks 管理
brew "direnv"       # 目录环境切换
#brew "rbw"          # 密码管理
brew "gitleaks"     # 密钥泄露扫描
brew "sops"
brew "age"
#brew "xdg-ninja"
brew "Copier"
#brew "cocogitto"

# --- Shell 交互层 ---
brew "zsh"
brew "sheldon"        # 极速插件管理
brew "atuin"          # 历史记录同步
brew "zoxide"         # 目录跳转
brew "carapace"       # 自动补全
brew "gum"            # 脚本交互 UI (编写脚本神器)
brew "plz-cli"

# --- 现代化终端工具---
brew "zellij"       # 终端复用 (tmux 替代者)
brew "helix"        # 模态编辑器 (vim 替代者)
brew "bat"          # cat 增强 (语法高亮)
brew "eza"          # ls 增强 (图标、Git状态)
brew "yazi"         # 文件管理器 (预览极快)
brew "fzf"          # 模糊搜索基石
brew "ripgrep"      # grep 替代 (rg)
brew "fd"           # find 替代
brew "tealdeer"     # tldr (man 手册简化版)
brew "difftastic"   # 语法感知 diff (用于代码审查)

# --- 数据处理流水线 ---
#brew "nushell"       # 结构化数据 Shell
brew "jaq"           # JSON 处理 (jq 的 Rust 版，更快)
brew "yq"
#brew "jnv"           # 交互式 JSON 过滤
brew "angle-grinder" # 命令行日志分析神器 (ag)
#brew "jc"            # 把非结构化输出转 JSON
brew "sd"            # sed 的直观替代品

# --- 安全工具 ---
#brew "trivy"
#brew "rustscan"
#brew "lynis"

# --- 监控与日志 ---
brew "btop"
brew "procs"          # ps 增强
brew "duf"            # df 增强
#brew "watchexec"      # 监控文件变动执行
brew "lnav"           # 日志查看器
brew "tailspin"       # log 高亮;tspin替代
brew "dust"           # du 增强
brew "viddy"          # watch 替代

# --- 网络工具 ---
brew "curlie"              # http/curl 增强
brew "doggo"           # dig 增强
brew "trippy"          # mtr 增强 (网络诊断)
#brew "croc"           # 局域网文件秒传
brew "mosh"
#brew "miniserve"      # 快速 HTTP 文件服
#brew "websocat"       # WebSocket 调试
#brew "zrok"           # 内网穿透 (类似 ngrok)

# --- 容器与虚拟化 ---
#brew "docker-compose"
brew "podman"
brew "podman-compose"
#brew "dive"         # 镜像层分析
#brew "hadolint"      # Dockerfile 检查
#brew "syft"           # SBOM 生成
#brew "k9s"
#brew "ctop"
brew "lazydocker"

# --- Git 工具 ---
brew "git-delta"
brew "git-lfs"
brew "tokei"          # 代码行统计
brew "lazygit"

# --- 测试与性能 ---
#brew "fio"            # 磁盘测试
#brew "oha"            # http 压测
#brew "ffuf"           # Web 模糊测试
#brew "hyperfine"      # 命令行基准测试

# --- 数据库 ---
#brew "sqlfluff"
#brew "gobackup"
#brew "usql" # 使用 tap xo/xo/usql

# --- 文档 ---
brew "glow"           # Markdown 渲染
#brew "pandoc"

# --- AI (CLI) ---
brew "aider"