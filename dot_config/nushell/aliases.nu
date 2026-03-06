#ls -laih
alias ll = ls -a | sort-by type name | update size { into filesize }

# 现代工具替代;如需使用原始命令，在 nushell 中用 ^ 前缀调用，例如 ^find
alias grep = rg                    # ripgrep: 更快的 grep
alias top = btop                   # btop: 更美观的系统监控
alias man = tldr                   # tealdeer: 简明版 man
alias rm = gtrash put              
alias curl = curlie                # curlie: httpie 风格的 curl
alias diff = delta                 # delta: 更美观的 diff
alias du = dust
alias cat = bat                    # 提醒:nushell的open查看结构化文件内容好用

# Git 常用
alias g = git
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

# TUI;普通终端用y,zellij中用yz
alias lg = lazygit
alias y = yazi
alias yz = with-env { YAZI_CONFIG_HOME: $"($env.HOME)/.config/yazi-zellij" } { yazi }