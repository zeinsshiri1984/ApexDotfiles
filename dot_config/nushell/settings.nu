# Static Nushell configuration

$env.config = {
  show_banner: false

  history: {
    max_size: 100_000
    sync_on_enter: false
    file_format: "plaintext"
  }

  completions: {
    case_sensitive: false
    quick: true
    partial: true
  }

  edit_mode: emacs
}
