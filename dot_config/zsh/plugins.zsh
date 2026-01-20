# fzf-tab
zstyle ':fzf-tab:*' use-fzf-default-opts yes                     # 禁用 fzf-tab 默认行为
zstyle ':fzf-tab:*' fzf-preview 'none'                           # 禁用预览窗口
# Noctis 主题 + 极低视觉噪声 + 动态高度
# --height=40%: 自适应高度，不超过屏幕 40%
# --layout=reverse: 列表从下往上延伸，符合视线习惯
# --border=rounded: 圆角边框，现代化
# --no-mouse: 纯键盘操作，提升性能
zstyle ':fzf-tab:*' fzf-flags \
    '--no-preview' \
    '--bind=tab:accept' \
    '--bind=right:accept' \
    '--height=~40%' \
    '--layout=reverse' \
    '--info=inline' \
    '--border=none' \
    '--padding=0' \
    '--margin=0' \
    '--no-mouse' \
    '--prompt=› ' \
    '--pointer=-→' \
    '--marker=+' \
    '--color=bg+:-1,bg:-1,fg:250,fg+:255' \
    '--color=hl:142,hl+:142' \
    '--color=header:109,info:242' \
    '--color=pointer:167,marker:167,spinner:109'

# 交互
zstyle ':fzf-tab:*' continuous-trigger '/'       # 输入 / 进入子目录 (级联补全)
zstyle ':fzf-tab:*' switch-group ',' '.'         # 使用 , . 在分组间快速跳转
zstyle ':fzf-tab:*' show-group yes               # 开启分组显示，否则没有 Header
zstyle ':fzf-tab:*' group-colors $'\033[38;5;109m'
zstyle ':fzf-tab:*' prefix ''                    # 不显示冗余的前缀符号

# --- zsh-autosuggestions幽灵补全设置 ---
# 策略：优先 Atuin 注入的历史，其次是补全引擎
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
# 极低视觉噪声颜色
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'