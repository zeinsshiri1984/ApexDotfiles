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
  keybindings: [
    {
      name: ai_ask
      modifier: alt
      keycode: char_a
      mode: [emacs, vi_insert]
      event: { send: executehostcommand cmd: "ai_ask" }
    }
    {
      name: ai_complete
      modifier: alt
      keycode: char_c
      mode: [emacs, vi_insert]
      event: { send: executehostcommand cmd: "ai_complete" }
    }
    {
      name: ai_fix
      modifier: alt
      keycode: char_f
      mode: [emacs, vi_insert]
      event: { send: executehostcommand cmd: "ai_fix" }
    }
  ]
}
