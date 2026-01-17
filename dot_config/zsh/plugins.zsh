# fzf-tab
zstyle ':fzf-tab:*' use-fzf-default-opts yes                     # 禁用 fzf-tab 默认行为
zstyle ':fzf-tab:*' fzf-preview 'none'                           # 禁用预览窗口
# Noctis 主题 + 极低视觉噪声 + 动态高度
# --height=40%: 自适应高度，不超过屏幕 40%
# --layout=reverse: 列表从下往上延伸，符合视线习惯
# --info=inline: 只有一行状态栏，极简
# --border=rounded: 圆角边框，现代化
# --no-mouse: 纯键盘操作，提升性能
zstyle ':fzf-tab:*' fzf-flags \
    '--no-preview' \
    '--bind=tab:accept' \
    '--height=40%' \
    '--layout=reverse' \
    '--info=hidden' \
    '--border=rounded' \
    '--no-mouse' \
    '--prompt=› ' \
    '--pointer=→' \
    '--marker=+' \
    '--color=bg+:-1,fg:248,fg+:255,border:240,spinner:109,hl:142' \
    '--color=prompt:109,header:109,pointer:208,marker:208'

# 交互
zstyle ':fzf-tab:*' continuous-trigger '/'       # 目录级联补全
zstyle ':fzf-tab:*' switch-group ',' '.'         # 使用 , . 在分组间快速跳转
zstyle ':fzf-tab:*' show-group yes               # 必须开启分组显示，否则没有 Header

# --- zsh-autosuggestions幽灵补全设置 ---
# 策略：优先 Atuin 注入的历史，其次是补全引擎
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
# 极低视觉噪声颜色
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'