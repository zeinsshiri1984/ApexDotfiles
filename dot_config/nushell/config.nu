$env.config = {
    show_banner: false
    edit_mode: vi
    shell_integration: true
    # Reduced flicker
    render_right_prompt_on_last_line: false 
}

# --- Cache Loader Helper ---
# Checks for cache file, generates if missing, then sources it
def source-or-create [name: string, cmd: string] {
    let cache_file = ($env.XDG_CACHE_HOME | path join $name "init.nu")
    if not ($cache_file | path exists) {
        mkdir ($cache_file | path dirname)
        # Use 'bash -c' as fallback if nu command fails, 
        # or execute the command string directly if it's a simple nu command
        if $name == "mise" {
            mise activate nu | save -f $cache_file
        } else if $name == "starship" {
            starship init nu | save -f $cache_file
        } else if $name == "atuin" {
            atuin init nu | save -f $cache_file
        } else if $name == "zoxide" {
            zoxide init nushell | save -f $cache_file
        }
    }
    source $cache_file
}

# --- Init Modules ---
source-or-create "mise" "mise activate nu"
source-or-create "starship" "starship init nu"
source-or-create "zoxide" "zoxide init nushell"
source-or-create "atuin" "atuin init nu"

# Carapace was generated in env.nu because it needs Env Vars to be set early? 
# Actually config.nu is fine. Let's load it here.
let carapace_cache = ($env.XDG_CACHE_HOME | path join "carapace" "init.nu")
if ($carapace_cache | path exists) {
    source $carapace_cache
}

# --- Import Submodules ---
# Put your aliases, functions, etc. in a 'modules' folder for cleanliness
let modules_path = ($nu.default-config-dir | path join "modules")
if ($modules_path | path exists) {
    for file in (ls ($modules_path | path join "*.nu")) {
        source $file.name
    }
}