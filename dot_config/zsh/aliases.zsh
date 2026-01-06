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
alias t='tldr'
alias sed='sd'
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
alias sh='bash' 

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

# 不需要安装额外工具，用 curl 直接拉取 gitignore.io 的 API
# 用法: gi rust,python,vscode >.gitignore
function gi() {
    curl -sL https://www.toptal.com/developers/gitignore/api/$@
}

# --- gh AI 助手集成 ---
# ask
alias '??'='gh copilot suggest -t shell'
# 解释上一条报错的命令
function wtf() {
  gh copilot explain "$(fc -ln -1)"
}
# 提交信息生成 (需安装 git plugin)
function gcm() {
    # 暂存区必须有内容
    if git diff --cached --quiet; then
        echo "❌ Staging area is empty."
        return 1
    fi
    
    echo "🤖 Generating commit message..."
    local msg
    msg=$(gh copilot suggest -t git "generate a concise commit message based on staged changes")

    # 3. 如果获取失败直接退出
    if [[ -z "$msg" ]]; then
        echo "❌ AI 未返回建议。"
        return 1
    fi
    
    # 使用 Gum 提供更优雅的编辑/确认体验
    # 用户可以在提交前最后修改一下 AI 生成的废话
    msg=$(gum input --value "$msg" --placeholder "Accept or edit commit message...")
    
    if [[ -n "$msg" ]]; then
        git commit -m "$msg"
    else
        echo "🚫 Commit aborted."
    fi
}

# 检查是否只有 Podman
if command -v podman &>/dev/null; then
    alias docker='podman'
    # 既然是 alias，为了防止某些脚本硬编码 /usr/bin/docker，
    # 建议在 bootstrap 脚本里做一个软链接或者 shim，但 alias 足够覆盖日常交互
    
    # 兼容 docker-compose
    alias docker-compose='podman-compose'
fi


alias d='docker'
alias dps='docker ps --format "json" | fjson | select ID Image Status Names | table'
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

# --- 项目生成器 ---
# 用法: new rust my_tool
function new() {
    local template_name="$1"
    local dest_dir="$2"
    local template_path="$HOME/.local/share/chezmoi/Templates/${template_name}_project"

    if [[ -z "$dest_dir" ]]; then
        echo "❌ 用法: new <template> <project_name>"
        echo "   可用模板: $(ls $HOME/.local/share/chezmoi/Templates | sed 's/_project//')"
        return 1
    fi

    if [[ ! -d "$template_path" ]]; then
         echo "❌ 模板不存在: $template_name"
         return 1
    fi

    # 1. 确保公钥存在 (供 Copier 使用)
    if [[ -z "$AGE_PUBLIC_KEY" ]]; then
        if [[ -f "$HOME/.config/sops/age/keys.txt" ]]; then
             export AGE_PUBLIC_KEY=$(grep "public key" "$HOME/.config/sops/age/keys.txt" | cut -d: -f2 | tr -d ' ')
        else
             echo "⚠️ 未找到 Age 公钥，生成的项目将无法配置自动加密。"
        fi
    fi

    echo "🚀 初始化项目: $dest_dir (模板: $template_name)..."
    
    # 2. 运行 Copier 生成项目
    copier copy "$template_path" "$dest_dir"
    
    # 3. 进入目录并初始化 Git
    cd "$dest_dir" || return
    
    if [ ! -d ".git" ]; then
        git init
        git add .
        # 4. 安装 Git 钩子
        if command -v lefthook &> /dev/null; then
            lefthook install
        fi
        echo "✅ Git 初始化完成 & Hooks 已安装"
    fi
    
    # 5. 允许 Direnv (这一步会触发 Devbox 安装和 Sops 解密准备)
    direnv allow
    
    echo "🎉 项目就绪！输入 'just' 查看可用命令。"
}

# 调用全局维护脚本工具
alias uuu='update-all'