$env.config = {
    show_banner: false
    edit_mode: vi
    shell_integration: true
    render_right_prompt_on_last_line: false
}

# 定义缓存路径 (使用常量字符串，或者在此处硬编码)
# Nushell 推荐尽量显式写出路径以加快解析
let mise_cache = ($env.XDG_CACHE_HOME | path join "mise" "init.nu")
let starship_cache = ($env.XDG_CACHE_HOME | path join "starship" "init.nu")
let atuin_cache = ($env.XDG_CACHE_HOME | path join "atuin" "init.nu")
let zoxide_cache = ($env.XDG_CACHE_HOME | path join "zoxide" "init.nu")

# 1. Mise (核心，必须最先加载)
if not ($mise_cache | path exists) {
    mkdir ($mise_cache | path dirname)
    ^mise activate nu | save -f $mise_cache
}
source ~/.cache/mise/init.nu  # <--- 必须是字面量路径，不能用变量

# 2. Starship
if not ($starship_cache | path exists) {
    ^starship init nu | save -f $starship_cache
}
source ~/.cache/starship/init.nu

# 3. Zoxide
if not ($zoxide_cache | path exists) {
    ^zoxide init nushell | save -f $zoxide_cache
}
source ~/.cache/zoxide/init.nu

# 4. Atuin
if not ($atuin_cache | path exists) {
    ^atuin init nu | save -f $atuin_cache
}
source ~/.cache/atuin/init.nu

# Carapace
let carapace_cache = ($env.XDG_CACHE_HOME | path join "carapace" "init.nu")
if ($carapace_cache | path exists) {
    source ~/.cache/carapace/init.nu
}

# Modules
let modules_path = ($nu.default-config-dir | path join "modules")
if ($modules_path | path exists) {
    for file in (ls ($modules_path | path join "*.nu")) {
        # 注意：这里也不能 source $file.name，这在旧版 nu 可能行，但在新版通常被禁止。
        # 建议手动 source 模块，或者使用 `use` 命令。
        # 临时解决方案：如果必须动态加载，目前 Nushell 比较困难，建议手动列出。
    }
}