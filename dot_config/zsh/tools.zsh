# Direnv (hook 模式，进入目录自动激活)
eval "$(direnv hook zsh)"

# Zoxide (目录跳转)
eval "$(zoxide init zsh)"

# Atuin (历史记录增强 - 绑定 Ctrl+R)
# 禁用 Up 键绑定，只用 Ctrl+R，保留 Shell 原生 Up 查找上一条习惯
eval "$(atuin init zsh --disable-up-arrow)"

# --- Carapace ---
export CARAPACE_BRIDGES='zsh,nushell,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
eval "$(carapace _carapace)"

# FZF (使用 fd 提速)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
# Ctrl+T 预览文件
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# --- 修复 Keybindings (解决 Up 键问题) ---
# 这一步必须在 Atuin 加载之后执行
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
# 绑定 Up/Down 到“前缀搜索”（输入 git 按 Up，只显示 git 开头的历史）
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# 确保 Ctrl+R 是 Atuin
bindkey '^r' _atuin_search_widget

# --- zsh-autosuggestions 设置---
# 建议的颜色（灰色）
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
# 自动建议的策略：优先匹配历史记录，其次是补全引擎
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# 关键：按右方向键接受建议
bindkey '^[C' autosuggest-accept
# 或者按 Ctrl+F 接受
bindkey '^f' autosuggest-accept

# Manpager (用 bat 看 man 手册)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"