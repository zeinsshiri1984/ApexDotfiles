# --- 现代工具替代 ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first -a'
alias tree='eza --tree --icons --group-directories-first'

alias cat='bat'    # 高亮查看
alias grep='rg'    # Ripgrep
alias find='fd'    # Fd

alias h='hx'
alias vi='hx'
alias vim='hx'

alias z='zellij'
alias zc='zellij attach -c'

alias cc='claude'
alias cx='codex'
alias gm='gemini'

alias top='btop'
alias ps='procs'
alias df='duf'
alias du='dust -d 1'
alias help='tldr'
alias t='tldr'
alias sed='sd'
alias jq='jaq'

# --- 网络工具增强 (Network) ---
alias curl='curlie'     
alias dig='doggo'
alias trace='trip'  # Trippy

# 常用
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear' 
alias c='clear'
alias x='exit'

# --- 安全操作 ---
alias cp='cp -i'
alias mv='mv -i'

alias rm='trash-put'     # 默认 rm 只是移动到回收站 (遵循 XDG: ~/.local/share/Trash)
alias rl='trash-list'    # 查看回收站内容
alias rc='trash-empty'   # 清空回收站
alias rs='trash-restore' # 还原文件 (交互式)
alias rmp='/bin/rm -vI'  # -v: 显示过程, -I: 删除超过3个文件时提示 (比 -i 智能)

# --- Git  ---
alias l='lazygit'
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gst='git status'
alias gd='git diff'
alias gp='git push'
alias gl='git pull'
alias l='lazygit' # 懒人神器

alias d='docker'
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'
alias dpsa='d ps -a'
alias di='d images'
alias dr='d run --rm -it'
alias dex='d exec -it'
alias dco='docker-compose'
alias dcp='docker-compose' # 兼容习惯
alias dcl='d logs -f --tail 100'
# 启动临时的 alpine 容器排查网络
alias debug='docker run --rm -it --net=host alpine sh'

# --- System & Tools ---
alias sc='systemctl'
alias scu='systemctl --user'
alias j='just'    # 任务运行
alias dx='devbox' # 项目环境