# Starship integration for Nushell
# This file must be side-effect free.

# assume starship init file existence is the gate
let init_file = $"($env.XDG_CONFIG_HOME)/starship/init.nu"
if not ($init_file | path exists) {
  return
}

let init_file = $"($env.XDG_CONFIG_HOME)/starship/init.nu"

if ($init_file | path exists) {
  source $init_file
}
