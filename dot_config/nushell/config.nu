$env.config = {
  show_banner: false

  history: {
    max_size: 100_000
    sync_on_enter: true
    file_format: "sqlite"
  }

  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
      enable: true # 必须开启，否则 Carapace 不工作
      max_results: 100
    }
  }

  edit_mode: emacs
  cursor_shape: {
    emacs: line
    vi_insert: line
    vi_normal: block
  }

}

source ($nu.default-config-dir | path join "cache/mise.nu")
source ($nu.default-config-dir | path join "cache/starship.nu")
source ($nu.default-config-dir | path join "cache/carapace.nu")

source aliases.nu
source functions.nu
source keybindings.nu