if ($env.config? | is-empty) {
  $env.config = {}
}
if ($env.config.keybindings? | is-empty) {
  $env.config.keybindings = []
}
$env.config.keybindings = ($env.config.keybindings | append [
  {
    name: "atuin_search"
    modifier: "control"
    keycode: "char_r"
    mode: "emacs"
    event: { send: executehostcommand cmd: "atuin search --interactive" }
  }
  {
    name: "ai_ask"
    modifier: "control"
    keycode: "char_a"
    mode: "emacs"
    event: { send: executehostcommand cmd: "nu -c ai-ask" }
  }
  {
    name: "ai_complete"
    modifier: "control"
    keycode: "char_y"
    mode: "emacs"
    event: { send: executehostcommand cmd: "nu -c ai-complete" }
  }
  {
    name: "ai_fix"
    modifier: "control"
    keycode: "char_f"
    mode: "emacs"
    event: { send: executehostcommand cmd: "nu -c ai-fix" }
  }
])
