# --- 原生 History 设置 (兜底用) ---
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=5000  # 本地只存少量，用于兜底
SAVEHIST=5000
setopt SHARE_HISTORY          # 多个终端共享历史
setopt HIST_EXPIRE_DUPS_FIRST # 空间不足时先删重复的  
setopt HIST_IGNORE_DUPS       # 不记录连续重复命令
setopt HIST_IGNORE_ALL_DUPS   # 删除旧的重复命令
setopt HIST_FIND_NO_DUPS      # 搜索时不显示重复的
setopt HIST_SAVE_NO_DUPS      # 保存时不写重复的
setopt HIST_IGNORE_SPACE      # 命令前加空格则不记录 (用于保护密码等)

# --- FZF-TAB 配置 ---
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # 忽略大小写
zstyle ':completion:*' menu no                            # 禁用默认菜单，交给 fzf-tab
zstyle ':fzf-tab:*' switch-group ',' '.'                  # 只有当终端够宽时才显示预览
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# 选中按 Tab 也可以接受
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept
# 显示参数的描述信息 (Description)
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:*:*:*:*' menu selection
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'

# 目录预览：用 Eza
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first -- "${realpath#--}"'
# 通用文件预览：Bat
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [ -d $realpath ]; then eza -1 --color=always --icons $realpath; else bat --color=always --style=numbers --line-range=:500 $realpath; fi'

# 命令/别名预览
zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
  '(whence -p $word || whence -f $word || whence -a $word) | bat -l sh --color=always --style=plain'

# kill 预览
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview \
  'ps --pid=$group -o cmd --no-headers -w -w'

# systemctl 预览
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$group -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
  'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null || echo "No status available"'

# 环境变量预览
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'

# Git checkout 预览
# 当输入 git checkout <tab> 时，显示 commit 内容
zstyle ':fzf-tab:complete:git-(checkout|switch|restore):*' fzf-preview \
  'git log -1 --color=always --format=fuller $word'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log -1 --color=always $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $word'

# Docker 预览
zstyle ':fzf-tab:complete:docker-(run|exec|rmi):*' fzf-preview 'docker inspect $word | jaq -C'
zstyle ':fzf-tab:complete:docker-logs:*' fzf-preview 'docker logs --tail 50 $word 2>&1 | bat --language=log --color=always --style=plain'
zstyle ':fzf-tab:complete:docker-inspect:*' fzf-preview 'docker inspect $word | jq -C .'
zstyle ':fzf-tab:complete:docker-exec:*' fzf-preview 'docker inspect $word | jq -C .[0].Config.Env'