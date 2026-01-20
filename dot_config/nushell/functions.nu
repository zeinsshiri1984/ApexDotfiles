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

def ask [...args] {
  if ($args | length) == 0 {
    print "Usage: ?? <natural language request>"
    return
  }
  print (char nl + "🤖 AI thinking...")
  let cmd = (^gh copilot suggest -t shell ($args | str join " ") | lines | where ($it | str starts-with "#") == false | where ($it | str length) > 0 | first)
  if ($cmd | is-empty) {
    print "❌ No suggestion found."
  } else {
    $env.CMD = $cmd
    commandline edit --replace $env.CMD
  }
}

def wtf [] {
  let prev_cmd = (history | last 1 | get 0.command)
  print $"🔍 Analyzing: ($prev_cmd)"
  ^gh copilot explain $prev_cmd
}

def gcm [] {
  let has_diff = (^git diff --cached --quiet; $env.LAST_EXIT_CODE) != 0
  if not $has_diff {
    print "🚫 Staging area empty."
    return
  }
  let msg = (^git diff --cached | ^mods "Generate a commit message based on these changes. Format: 'feat: description'. One line only. No quotes.")
  let input = (^gum input --value $msg --width 80 --placeholder "Commit message...")
  if ($input | is-empty) {
    return
  }
  ^git commit -m $input
}

def new [type: string, name: string] {
  let template = ($env.HOME | path join ".local" "share" "chezmoi" "Templates" $"($type)_project")
  if not ($template | path exists) {
    print $"❌ Template '($type)' not found."
    return
  }
  ^copier copy $template $name
  cd $name
  ^git init
  ^direnv allow
  print $"🎉 Project ($name) initialized!"
}

def y [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXXX")
  let config_home = ($env.HOME | path join ".config" "yazi")
  mut envs = { YAZI_CONFIG_HOME: $config_home }
  if ($env.ZELLIJ? | is-not-empty) or ($env.SSH_CONNECTION? | is-not-empty) {
    $envs = ($envs | upsert YAZI_CONFIG_HOME ($config_home | path join "lite_env") | upsert YAZI_IMAGE_PREVIEW "0")
  }
  with-env $envs {
    ^yazi ...$args --cwd-file $tmp
  }
  let cwd = (open $tmp | str trim)
  if ($cwd | is-not-empty) and ($cwd != (pwd | str trim)) {
    cd $cwd
  }
  ^rm -f $tmp
}

def ai-ask [] {
  let q = (^gum input --placeholder "Ask AI..." --width 80)
  if ($q | is-empty) { return }
  ^mods $q
}

def ai-complete [] {
  let s = (^gum input --placeholder "Base command/text to complete..." --width 80)
  if ($s | is-empty) { return }
  ^mods $"Complete the following succinctly:\n($s)"
}

def ai-fix [] {
  let e = (^gum input --placeholder "Paste error/output to fix..." --width 80)
  if ($e | is-empty) { return }
  ^mods $"Generate a shell command to fix:\n($e)"
}

def bw-set-env [name: string, item_id: string, field: string] {
  let item = (^bw get item $item_id | from json)
  let val = ($item.fields | where name == $field | get 0.value)
  if ($val | is-empty) { print $"❌ Field not found: ($field)"; return }
  $env = ($env | upsert $name $val)
  print $"✅ Set env: ($name)"
}

def notify [topic: string, msg: string] {
  if (which ntfy | is-empty) { print "ntfy not installed"; return }
  ^ntfy pub $topic $msg
}

def ding [] {
  if (which canberra-gtk-play | is-empty) {
    print (char bell)
  } else {
    ^canberra-gtk-play -i complete
  }
}
}

def voice [] {
  if (which whisper-typist | is-empty) { print "whisper-typist not installed"; return }
  ^whisper-typist
}
