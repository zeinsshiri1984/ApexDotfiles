# Nushell aliases (Nu-native only)

alias ll = ls -l
alias la = ls -a
alias lla = ls -la

alias g = git
def --wrapped j [...args] {
  let justfile = (($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config")) | path join "just" "justfile")
  ^just --justfile $justfile ...$args
}
