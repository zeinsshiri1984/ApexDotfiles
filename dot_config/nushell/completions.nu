# Carapace 补全集成

if (which carapace | is-empty) { return }

let carapace_completer = {|spans: list<string>|
  carapace _carapace nushell ...$spans | from json | default []
}

$env.config = ($env.config | upsert completions.external {
  enable: true
  completer: $carapace_completer
})
