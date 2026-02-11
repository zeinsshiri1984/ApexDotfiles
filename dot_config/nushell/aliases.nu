alias ll = ls -l
alias la = ls -a
alias lla = ls -la
alias g = git

# 现代工具替代;如需使用原始命令，在 nushell 中用 ^ 前缀调用，例如 ^find
alias find = fd                    # fd: 更快的 find
alias grep = rg                    # ripgrep: 更快的 grep
alias du = dust                    # dust: 更直观的磁盘用量
alias top = btop                   # btop: 更美观的系统监控
alias man = tldr                   # tealdeer: 简明版 man
alias rm = gtrash put              # gtrash: 安全删除到回收站
alias curl = curlie                # curlie: httpie 风格的 curl
alias diff = delta                 # delta: 更美观的 diff
alias watch = viddy                # viddy: 更强的 watch

# Git 常用
alias gs = git status -sb
alias ga = git add
alias gc = git commit
alias gco = git checkout
alias gsw = git switch
alias gbr = git branch -vv
alias gd = git diff
alias gds = git diff --staged
alias gl = git log --graph --decorate --oneline --all

# Zellij
alias z = zellij
alias za = zellij attach
alias zl = zellij list-sessions

# TUI
alias lg = lazygit
alias y='yazi' # 普通终端
alias yz='YAZI_CONFIG_HOME=$HOME/.config/yazi-zellij yazi'  # zellij 内
