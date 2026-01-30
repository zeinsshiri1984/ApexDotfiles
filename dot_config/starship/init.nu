if ($nu.is-interactive? | default false) {
  let-env STARSHIP_SHELL = "nu"
  let-env PROMPT_COMMAND = {|| ^starship prompt }
  let-env PROMPT_COMMAND_RIGHT = {|| ^starship prompt --right }
  let-env PROMPT_INDICATOR = {|| ^starship prompt --indicator }
  let-env PROMPT_INDICATOR_VI_INSERT = {|| ^starship prompt --vi-insert }
  let-env PROMPT_INDICATOR_VI_NORMAL = {|| ^starship prompt --vi-normal }
  let-env PROMPT_MULTILINE_INDICATOR = {|| ^starship prompt --continuation }
}
