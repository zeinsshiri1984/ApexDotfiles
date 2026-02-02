# Nushell 静态配置

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
  }

  edit_mode: emacs
  cursor_shape: {
    emacs: line
    vi_insert: line
    vi_normal: block
  }

}
