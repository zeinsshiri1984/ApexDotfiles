# --- 现代工具替代 ---
alias ls='eza --icons --git --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first -a'
alias tree='eza --tree --icons --group-directories-first'

alias cat='bat'    # 高亮查看
alias grep='rg'    # Ripgrep
alias find='fd'    # Fd
# Zoxide 接管 cd (不再需要输入 z code，直接 cd code)
eval "$(zoxide init zsh --cmd cd)"

alias z='zellij'
alias h='hx'
alias vi='hx'
alias vim='hx'

alias top='btop'
alias ps='procs'
alias df='duf'
alias du='dust -d 1'
alias help='tldr'
alias sed='sd'
alias help='tldr'
alias jq='jaq'

alias y='yazi'

# --- 网络工具增强 (Network) ---
alias curl='curlie'     
alias dig='doggo'
alias trace='trip'  # Trippy

# 常用
alias ...='cd ../..'
alias ....='cd ../../..'
alias cl='clear'

# --- 安全操作 ---
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i' 

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

# --- Nushell 数据处理快捷键 ---
# 场景：Docker 进程 -> JSON -> 过滤字段 -> 表格展示
# 用法: dps | fjson | select State Status | table
# 数据转换
alias fjson='nu -c "from json"'
alias fyaml='nu -c "from yaml"'
alias ftoml='nu -c "from toml"'
alias fcsv='nu -c "from csv"'

# 强大的表格查看器 (配合管道用)
alias table='nu -c "table"'

# --- Docker / Podman (兼容性别名) ---
# 智能检测：如果有 podman 且没有 docker，则 d=podman
if ! command -v docker &> /dev/null && command -v podman &> /dev/null; then
    alias d='podman'
else
    alias d='docker'
fi

alias dps='d ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'
alias dpsa='d ps -a'
alias di='d images'
alias dr='d run --rm -it'
alias dex='d exec -it'
alias dco='docker-compose'
alias dcp='docker-compose' # 兼容习惯
alias dcl='d logs -f --tail 100'

# --- System & Tools ---
alias sc='systemctl'
alias scu='systemctl --user'
alias j='just'    # 任务运行
alias dx='devbox' # 项目环境