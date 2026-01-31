# Static Nushell configuration

$env.config = {
  show_banner: false

  history: {
    max_size: 100_000
    sync_on_enter: false
    file_format: "plaintext"
  }

  completions: {
    case_sensitive: false
    quick: true
    partial: true
  }

  edit_mode: emacs
}

if ($nu.is-interactive? | default false) {
  if (which carapace | is-empty) == false {
    let carapace_completer = {|spans: list<string>|
      do -i { ^carapace _carapace nushell ...$spans | from json } | default []
    }

    let completions = ($env.config.completions? | default {})
    let external = ($completions.external? | default {})
    let external = ($external | upsert enable true | upsert completer $carapace_completer)
    let completions = ($completions | upsert external $external)
    $env.config = ($env.config | upsert completions $completions)
  }
}
