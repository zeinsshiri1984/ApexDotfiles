if (which starship | is-empty) { return }

$env.STARSHIP_SHELL = "nu"
starship init nu | save -f ~/.cache/starship.nu
source ~/.cache/starship.nu