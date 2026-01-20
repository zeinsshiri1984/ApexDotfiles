#mise
zsh-defer -c 'eval "$(mise activate zsh)"'

# Zoxide (接管 cd)
eval "$(zoxide init zsh --cmd cd)"

# Atuin (History Sync & Ctrl+R)
eval "$(atuin init zsh --disable-up-arrow)" # 禁用 Up 键接管，我们用 substring-search

# Carapace 注入补全路径，放在 Atuin 之后，Compinit 之后
# 用 function 包装以避免污染全局命名空间，并设为 fallback
function _init_carapace() {
    source <(carapace _carapace)
}
zsh-defer -t 0.05 _init_carapace  # 极短延迟加载，确保不阻塞 Prompt，但能快速响应第一次 Tab

# FZF
# Noctis 默认主题
export FZF_DEFAULT_OPTS=" \
--height 40% \
--layout=reverse \
--info=inline \
--border=none \
--margin=0 --padding=0 \
--prompt='› ' --pointer='-→' --marker='+' \
--color=bg+:-1,bg:-1,fg:250,fg+:255 \
--color=hl:142,hl+:142,header:109 \
--color=info:242,pointer:167,marker:167,spinner:109"
# fd 替代 find提速、忽略 .git、忽略隐藏文件
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Manpager(用 bat 看 man 手册)
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
