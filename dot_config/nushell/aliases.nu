# Nushell 别名

alias ll = ls -l
alias la = ls -a
alias lla = ls -la
alias g = git

# Git 常用
alias gs = git add -A && git commit -m "待生成" && git push 
alias gs = git status -sb
alias ga = git add
alias gc = git commit
alias gco = git checkout
alias gsw = git switch
alias gbr = git branch -vv
alias gd = git diff
alias gds = git diff --staged
alias gl = git log --graph --decorate --oneline --all

# TUI
alias lg = lazygit
alias y = yazi

# just 使用全局 justfile
def --wrapped j [...args] {
  let justfile = $"($env.XDG_CONFIG_HOME? | default $"($env.HOME)/.config")/just/justfile"
  ^just --justfile $justfile ...$args
}

# Zellij 快速启动
alias zj = zellij
alias zja = zellij attach
alias zjl = zellij list-sessions
