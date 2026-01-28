# === 基础行为 ===
$env.config = {
  show_banner: false
  edit_mode: emacs
}

# === 让 Nu 识别 Bash 注入的 PATH ===
# 什么都不做（这是重点）

# === 交互增强（纯消费型） ===
use ~/.config/nushell/starship.nu
use ~/.config/nushell/atuin.nu
use ~/.config/nushell/zoxide.nu
