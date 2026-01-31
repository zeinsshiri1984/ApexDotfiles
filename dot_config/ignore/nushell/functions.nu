def gi [...args] {
  if ($args | length) == 0 {
    print "Usage: gi <list|search TERM|LANG1,LANG2...>"
    return
  }
  if $args.0 == "list" {
    ^curl -sL https://www.toptal.com/developers/gitignore/api/list | tr ',' "\n"
  } else if $args.0 == "search" and ($args | length) > 1 {
    ^curl -sL https://www.toptal.com/developers/gitignore/api/list | tr ',' "\n" | rg -i $args.1
  } else {
    ^curl -sL $"https://www.toptal.com/developers/gitignore/api/($args | str join ',')"
  }
}

def gl [] {
  ^git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all
}

def new [type: string, name: string] {
  let chezmoi_source = if (which chezmoi | is-not-empty) {
    try {
      (^chezmoi source-path | lines | first | str trim)
    } catch {
      ""
    }
  } else {
    ""
  }

  let templates_dir = if ($chezmoi_source | is-not-empty) {
    ($chezmoi_source | path join "Templates")
  } else {
    ($env.HOME | path join ".local" "share" "chezmoi" "Templates")
  }

  if not ($templates_dir | path exists) {
    print $"❌ Templates dir not found: ($templates_dir)"
    return
  }

  if ($name | path exists) {
    print $"❌ Target already exists: ($name)"
    return
  }

  let candidates = [
    ($templates_dir | path join $type)
    ($templates_dir | path join $"($type)_project")
  ]
  let matches = ($candidates | where {|p| $p | path exists })
  if ($matches | is-empty) {
    let available = (ls $templates_dir | where type == dir | get name | sort)
    print $"❌ Template '($type)' not found."
    print $"Available: ($available | str join ', ')"
    return
  }
  let template = $matches.0
  let copier_cfg = ($template | path join "copier.yaml")
  if ($copier_cfg | path exists) and (which copier | is-not-empty) {
    let cfg_text = (open $copier_cfg | into string)
    mut args = ["copy" "--defaults"]
    if ($cfg_text | str contains "project_name:") {
      $args = ($args | append ["--data" $"project_name=($name)"])
    }
    if ($cfg_text | str contains "module_path:") {
      $args = ($args | append ["--data" $"module_path=($name)"])
    }
    if (which just | is-empty) {
      $args = ($args | append ["--skip-tasks"])
    }
    ^copier ...($args | append [$template $name])
  } else if ($copier_cfg | path exists) and (which copier | is-empty) {
    print "⚠️  copier not installed; falling back to plain copy."
    ^mkdir $name
    ^cp -a $"($template)/." $name
  } else {
    ^mkdir $name
    ^cp -a $"($template)/." $name
  }
  cd $name
  if not (".git" | path exists) {
    ^git init
  }
  print $"🎉 Project ($name) initialized!"
}
