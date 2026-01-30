# Nushell entrypoint
# This file must be static and side-effect free.

let config_dir = $nu.default-config-dir

source ($config_dir | path join "settings.nu")

let hook = ($config_dir | path join "hook.nu")
if ($hook | path exists) {
  source $hook
}

source ($config_dir | path join "aliases.nu")
source ($config_dir | path join "functions.nu")
