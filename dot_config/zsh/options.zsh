# --- 历史记录策略 (配合 Atuin 使用)
HISTSIZE=1000000        # 内存中保留的历史数量
SAVEHIST=1000000        # 文件中保存的历史数量
setopt INC_APPEND_HISTORY     # 立即追加到文件 (让 Atuin 实时看到)
setopt SHARE_HISTORY          # 允许共享 (Atuin 会处理同步，Zsh 负责读取)
setopt HIST_EXPIRE_DUPS_FIRST # 空间不足删重复
setopt HIST_IGNORE_DUPS       # 忽略连续重复
setopt HIST_IGNORE_ALL_DUPS   # 删除旧重复
setopt HIST_FIND_NO_DUPS      # 搜索不显示重复
setopt HIST_SAVE_NO_DUPS      # 保存不含重复
setopt HIST_IGNORE_SPACE      # 空格开头不记录 (用于保护密码等)

#交互
setopt NO_BEEP                # 禁止蜂鸣
setopt AUTO_CD                # 目录名直接跳转
setopt INTERACTIVE_COMMENTS   # 允许在交互式 Shell 中输入 # 注释
setopt NO_NOMATCH             # 通配符不匹配不报错(交给应用处理)
setopt AUTO_PUSHD             # cd 自动压栈
setopt PUSHD_IGNORE_DUPS      # 栈去重
setopt PUSHD_SILENT           # 静默压栈
setopt NO_LIST_BEEP           # 列表补全不蜂鸣

# --- Zsh 补全引擎 (Compinit 行为)---
setopt GLOB_COMPLETE        # Tab 触发通配符补全
setopt EXTENDED_GLOB        # 扩展通配符
setopt NO_CASE_GLOB         # 通配符不区分大小写

autoload -Uz compinit       # 初始化补全系统
zstyle ':completion:*' use-cache on                       # 开启缓存以加速
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
# 检查缓存是否在 24h 内，如果是则直接用，否则重新生成
# -d 指定转储文件，-C 表示忽略检查（加速），但如果是新环境去掉 -C
if [[ -n "$ZSH_COMPDUMP"(#qN.mh-24) ]]; then
    compinit -d "$ZSH_COMPDUMP" -C
else
    compinit -d "$ZSH_COMPDUMP"
fi

# 匹配策略: 大小写不敏感 -> 模糊匹配
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

#菜单与显示行为
zstyle ':completion:*' menu no                            # 禁用原生菜单，交给 fzf-tab
zstyle ':completion:*' sort false                            # 禁用默认排序,交给 fzf 排序
zstyle ':completion:*' file-sort modification             # 排序
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"      # 使用 ls 颜色
zstyle ':completion:*' prefix-hidden yes
zstyle ':completion:*' insert-tab false  # 禁止在空行按 Tab 触发补全

# 分组与描述
zstyle ':completion:*' group-name ''                      # 开启自动分组
zstyle ':completion:*' description 'yes'                  # 启用一般描述
zstyle ':completion:*:options' verbose yes                # 显示选项的详细说明
zstyle ':completion:*:options' description 'yes'          # 强制为选项启用描述
zstyle ':completion:*:options' auto-description '%d'      # 自动生成描述

# 格式化：Noctis 风格，低视觉噪声
zstyle ':completion:*:descriptions' format $'\n\033[38;5;109m── %d ──\033[0m'
zstyle ':completion:*:messages' format $'\033[38;5;109m── %d ──\033[0m'
zstyle ':completion:*:warnings' format $'\033[38;5;167m── No Matches ──\033[0m'

#列表过滤
zstyle ':completion:*:cd:*' ignore-parents parent pwd              # 防止 cd 补全 . 和 ..
zstyle ':completion::complete:-command-::*' ignored-patterns '*\~' # 忽略备份文件
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories # 强制 cd 只补全目录