# 使用函数封装，配合 zsh-defer 确保所有插件加载完毕后执行
function _apply_keybindings() {
    
    # --- History Substring Search (Up/Down) ---
    # 绑定标准方向键
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    # 绑定 Vim 模式
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
    # 兼容 Terminfo
    if [[ -n "${terminfo[kcuu1]}" ]]; then
      bindkey "${terminfo[kcuu1]}" history-substring-search-up
      bindkey "${terminfo[kcud1]}" history-substring-search-down
    fi

    # Atuin Search (Ctrl+R)
    bindkey '^r' _atuin_search_widget

    # Autosuggestions
    bindkey '^[C' autosuggest-accept         # 右方向键接受建议
    bindkey '^S' autosuggest-partial-accept  # Ctrl + S -> 逐词接受 (Partial)
    
    # FZF-Tab
    bindkey '^[[Z' reverse-menu-complete # Shift+Tab 反向选择补全菜单
}

# 延迟执行，避开竞态条件
zsh-defer _apply_keybindings