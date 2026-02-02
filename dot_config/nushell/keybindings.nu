# AI 快捷键

$env.config = ($env.config | upsert keybindings [
  {
    name: ai_complete
    modifier: control
    keycode: char_o
    mode: [emacs vi_insert]
    event: { send: executehostcommand cmd: "ai_complete" }
  }
  {
    name: ai_fix
    modifier: control
    keycode: char_f
    mode: [emacs vi_insert]
    event: { send: executehostcommand cmd: "ai_fix" }
  }
  {
    name: ai_commit
    modifier: control
    keycode: char_g
    mode: [emacs vi_insert]
    event: { send: executehostcommand cmd: "ai_commit" }
  }
])
