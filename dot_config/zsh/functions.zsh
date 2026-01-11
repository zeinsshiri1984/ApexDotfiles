# 不需要安装额外工具，用 curl 直接拉取 gitignore.io 的 API
# 用法: gi rust,python,vscode >.gitignore
function gi() {
    curl -sL https://www.toptal.com/developers/gitignore/api/$@
}

# --- gh AI 助手集成 ---
function ask() {
    if [[ -z "$1" ]]; then
        echo "Usage: ?? <natural language request>"
        return 1
    fi
    
    echo -ne "\033[34m🤖 AI thinking...\033[0m\r"
    
    # 注意: gh copilot suggest 的输出格式可能变动，这里使用 -t shell
    # 更好的方式是直接用 copilot 的 execute 模式，但为了 Buffer Stack 体验：
    local cmd=$(gh copilot suggest -t shell "$*" 2>/dev/null | grep -v '^#' | sed '/^$/d' | head -n 1)

    if [[ -n "$cmd" ]]; then
        # print -z 将内容推送到 Zsh 的编辑缓冲区
        print -z "$cmd"
    else
        echo "❌ No suggestion found."
    fi
}

# 用法: 报错后直接输 wtf;或解释上一条命令
function wtf() {
    local prev_cmd=$(fc -ln -1)
    echo "🔍 Analyzing: $prev_cmd"
    gh copilot explain "$prev_cmd"
}

function gcm() {
    git diff --cached --quiet && echo "🚫 Staging area empty." && return 1

    # 生成 commit message
    local msg=$(git diff --cached | mods "Generate a commit message based on these changes. Format: 'feat: description'. One line only. No quotes.")

    # 使用 gum 交互式让用户确认或修改，然后提交
    gum input --value "$msg" --width 80 --placeholder "Commit message..." | xargs -r -0 -I {} git commit -m "{}"
}

# --- 项目生成器 ---
# 用法: new rust my-api
function new() {
    local type=$1
    local name=$2
    local template="$HOME/.local/share/chezmoi/Templates/${type}_project"
    
    if [[ ! -d "$template" ]]; then
        echo "❌ Template '$type' not found."
        return 1
    fi
    
    # 使用 Copier (Brew 安装) 渲染模板
    copier copy "$template" "$name"
    
    cd "$name" || return
    git init
    direnv allow
    
    echo "🎉 Project $name initialized!"
}

# Yazi Shell Wrapper: 退出 yazi 时自动 cd 到最后所在的目录
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

#已存在 Session 则直接进入，否则按 IDE 布局新建
function zc() {
    local name="${1:-$(basename "$PWD" | tr '.-' '__')}"
    # 检查会话是否存在
    if zellij list-sessions -n | grep -q -w "$name"; then
        zellij attach "$name"
    else
        # 强制使用 ide 布局
        zellij --session "$name" --layout ide
    fi
}