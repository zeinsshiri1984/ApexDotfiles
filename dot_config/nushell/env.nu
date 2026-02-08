let cache = ($nu.default-config-dir | path join "cache")
if not ($cache | path exists) { mkdir $cache }

#mise
^mise activate nu | save --force ($nu.default-config-dir | path join "cache/mise.nu")

# Starship
^starship init nu | save --force ($nu.default-config-dir | path join "cache/starship.nu")

# Carapace-bin
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' 
^carapace _carapace nushell | save --force ($nu.default-config-dir | path join "cache/carapace.nu")