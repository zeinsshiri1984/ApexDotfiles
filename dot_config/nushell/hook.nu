# Starship integration for Nushell
# This file must be side-effect free.
if ($nu.is-interactive? | default false) == false {
  return
}

let carapace_completer = {|spans: list<string>|
  if (which carapace | is-empty) {
    []
  } else {
    do -i { ^carapace _carapace nushell ...$spans | from json } | default []
  }
}

let completions = ($env.config.completions? | default {})
let external = ($completions.external? | default {})
let external = ($external | upsert enable true | upsert completer $carapace_completer)
let completions = ($completions | upsert external $external)
$env.config = ($env.config | upsert completions $completions)

if (which starship | is-empty) {
  return
}

let starship_init = ($env.XDG_CONFIG_HOME | path join "starship" "init.nu")
if not ($starship_init | path exists) {
  return
}

source $starship_init
