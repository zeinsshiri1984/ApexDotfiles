# Starship 提示符集成

if (which starship | is-empty) { return }

$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
  starship prompt --cmd-duration $env.CMD_DURATION_MS $"--status=($env.LAST_EXIT_CODE)"
}

def create_right_prompt [] {
  starship prompt --right --cmd-duration $env.CMD_DURATION_MS $"--status=($env.LAST_EXIT_CODE)"
}

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = "::: "
