#!/bin/zsh

# --- 系统自动维护脚本,异步、静默、不阻塞 Shell 启动 ---

# 定义清理函数
function _perform_maintenance() {
    if command -v trash-empty >/dev/null 2>&1; then
        # 清理超过 30 天的回收站文件
        # >/dev/null 2>&1 确保没有任何输出干扰用户
        trash-empty 30 >/dev/null 2>&1
    fi
}

# 检查上次运行时间 (使用修改时间标记)
MAINTAIN_STATE="$XDG_STATE_HOME/zsh/.last_maintenance"
WEEKLY_UPDATE_STATE="$XDG_STATE_HOME/zsh/.last_weekly_update"

# 如果状态文件不存在，或者上次修改时间超过 24 小时 (+1)
if [[ ! -f "$MAINTAIN_STATE" ]] || [[ -n $(find "$MAINTAIN_STATE" -mtime +1 2>/dev/null) ]]; then
    
    # 更新时间戳 (相当于 touch)
    : > "$MAINTAIN_STATE"
    
    # 放入后台子 shell 执行，彻底不卡顿
    # 使用 disconnect (&!) 让其与当前 shell 进程解绑，防止关闭终端时报错
    (_perform_maintenance) &!
fi

if [[ ! -f "$WEEKLY_UPDATE_STATE" ]] || [[ -n $(find "$WEEKLY_UPDATE_STATE" -mtime +7 2>/dev/null) ]]; then
    : > "$WEEKLY_UPDATE_STATE"
    if command -v update-all >/dev/null 2>&1; then
        (update-all >/dev/null 2>&1) &!
    fi
fi
