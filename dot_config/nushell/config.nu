$env.config = {
  show_banner: false

  history: {
    max_size: 100_000
    sync_on_enter: true
    file_format: "sqlite"
    include_duplicates: false
    isolation: false  # 所有 Shell 共享同一个 sqlite 文件
  }

  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
      enable: true # 必须开启，否则 Carapace 不工作
      max_results: 50
    }
  }

  edit_mode: emacs
}

source ($nu.default-config-dir | path join "cache/mise.nu")
source ($nu.default-config-dir | path join "cache/starship.nu")
source ($nu.default-config-dir | path join "cache/carapace.nu")

source aliases.nu
source functions.nu