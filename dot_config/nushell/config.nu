let starship_cache = ($nu.cache-path | path join "starship" "init.nu")
if not ($starship_cache | path exists) {
  mkdir --parents ($starship_cache | path dirname)
  starship init nu | save -f $starship_cache
}
source $starship_cache

let atuin_cache = ($nu.cache-path | path join "atuin" "init.nu")
if not ($atuin_cache | path exists) {
  mkdir --parents ($atuin_cache | path dirname)
  atuin init nu | save -f $atuin_cache
}
source $atuin_cache

let carapace_cache = ($nu.cache-path | path join "carapace" "init.nu")
if not ($carapace_cache | path exists) {
  mkdir --parents ($carapace_cache | path dirname)
  carapace _carapace nushell | save -f $carapace_cache
}
source $carapace_cache

let mise_cache = ($nu.cache-path | path join "mise" "init.nu")
if not ($mise_cache | path exists) {
  mkdir --parents ($mise_cache | path dirname)
  mise activate nu | save -f $mise_cache
}
source $mise_cache

def --wrapped run-bash [script: path, ...args] {
  ^bash $script ...$args
}

let modules = [
  ($nu.config-path | path dirname | path join "aliases.nu")
  ($nu.config-path | path dirname | path join "functions.nu")
  ($nu.config-path | path dirname | path join "hooks.nu")
  ($nu.config-path | path dirname | path join "maintain.nu")
  ($nu.config-path | path dirname | path join "keybindings.nu")
]
for module in $modules {
  if ($module | path exists) {
    source $module
  }
}
