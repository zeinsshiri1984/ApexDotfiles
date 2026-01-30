# Starship integration for Nushell
# This file must be side-effect free.
if ($nu.is-interactive? | default false) == false {
  return
}

# assume starship init file existence is the gate
if (which starship | is-empty) {
  return
}

let starship_init = ($env.XDG_CONFIG_HOME | path join "starship" "init.nu")
if not ($starship_init | path exists) {
  return
}

source $starship_init
