#  curl拉取 gitignore.io 的 API
# 生成: gi rust,windows,macos,linux,vscovisualstudiocode >.gitignore
# 搜索: gi search type   (会输出所有包含 type 的模板，如 typo3, types, etc.)
# 列出所有支持的模板: gi list          ()
function gi() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: gi <list|search TERM|LANG1,LANG2...>"
        return 1
    fi

    if [[ "$1" == "list" ]]; then
        curl -sL https://www.toptal.com/developers/gitignore/api/list | tr ',' '\n'
    elif [[ "$1" == "search" && -n "$2" ]]; then
        # 从列表中过滤关键词
        curl -sL https://www.toptal.com/developers/gitignore/api/list | tr ',' '\n' | grep -i "$2"
    else
        # 生成 ignore 文件
        curl -sL https://www.toptal.com/developers/gitignore/api/"$@"
    fi
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
    local config_home="$HOME/.config/yazi"
    
    # 1. 环境检测逻辑
    # 如果在 Zellij 中，或者 SSH 连接中，或者终端不支持图形协议(这里用简单的 TERM 判断，可根据情况调整)
    # 强制切换到 "Lite" 轻量环境
    if [[ -n "$ZELLIJ" ]] || [[ -n "$SSH_CONNECTION" ]]; then
        # 指向 Lite 配置目录 (你可以复用你现有的结构)
        export YAZI_CONFIG_HOME="$config_home/lite_env"
        # 显式告诉 Yazi 关闭图像适配器（双保险）
        export YAZI_IMAGE_PREVIEW=0
    else
        # 桌面全功能模式
        export YAZI_CONFIG_HOME="$config_home"
        unset YAZI_IMAGE_PREVIEW
    fi

    # 2. 启动 Yazi
    yazi "$@" --cwd-file="$tmp"

    # 3. 退出后目录跳转
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}