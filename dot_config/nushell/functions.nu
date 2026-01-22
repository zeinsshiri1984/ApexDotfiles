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

def f [...args] {
  # 统一文件管理器入口
  # Zellij 环境下 -> Superfile (spf)
  # 普通终端环境 -> Yazi (y)
  if ($env.ZELLIJ? | is-not-empty) {
    if (which spf | is-not-empty) {
      ^spf ...$args
    } else if (which superfile | is-not-empty) {
      ^superfile ...$args
    } else {
      y ...$args
    }
  } else {
    y ...$args
  }
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
  let q = (commandline)
  if ($q | is-empty) { 
    print "Usage: Type query in buffer then press Alt+a"
    return 
  }
  
  print (char nl)
  print "🤖 AI Thinking..."
  
  # 调用 mods (Fabric 也是很好的选择，但 mods 更通用)
  let answer = ($q | ^mods --no-limit -f)
  
  # 输出结果到 stdout (不替换 buffer，因为这通常是问答)
  print $answer
  
  # 换行并重绘 prompt
  print (char nl)
}

def ai-complete [] {
  let s = (commandline)
  if ($s | is-empty) { return }
  
  print (char nl)
  print "🤖 AI Completing..."
  
  # 要求 AI 只返回补全后的完整命令，不要 Markdown，不要解释
  let prompt = $"Complete this shell command. Return ONLY the completed command. No markdown. No explanation.\n\n($s)"
  let completion = ($prompt | ^mods -q --no-limit)
  
  # 替换 buffer
  commandline edit --replace ($completion | str trim)
}

def ai-fix [] {
  # 获取上一条命令的退出码和输出（这比较难，因为上一条命令已经跑完了）
  # 替代方案：让用户粘贴报错，或者获取 history 的最后一条命令并尝试修复
  
  let prev_cmd = (history | last 1 | get 0.command)
  
  print (char nl)
  print $"🤖 AI Fixing: ($prev_cmd)..."
  
  let prompt = $"The following shell command failed or needs fixing:\n\n($prev_cmd)\n\nProvide a fixed version. Return ONLY the fixed command. No markdown. No explanation."
  let fixed = ($prompt | ^mods -q --no-limit)
  
  commandline edit --replace ($fixed | str trim)
}

def bw-load [item_id: string] {
  # 从 Bitwarden 读取 item 并将所有 fields 注入为环境变量
  # 用法: bw-load <item_id>
  # 依赖: bw cli 且已登录
  
  if (which bw | is-empty) {
    print "❌ Bitwarden CLI (bw) not installed."
    return
  }
  
  if ($env.BW_SESSION? | is-empty) {
    print "⚠️  BW_SESSION not found. Please login/unlock first:"
    print "   $env.BW_SESSION = (bw unlock --raw)"
    return
  }

  print $"🔓 Loading secrets from item: ($item_id)..."
  let item = (^bw get item $item_id | from json)
  
  # 遍历 fields 并注入环境
  # 注意：Nushell 的环境变量是 Scoped 的，这个函数只能导出到当前 Scope
  # 若要持久化到当前 Session，需要在调用处使用 `load-env`
  # 但函数无法直接修改父作用域的 env，除非返回 record 让调用者 load-env
  
  let secrets = ($item.fields | reduce -f {} {|it, acc| 
    $acc | insert $it.name $it.value 
  })
  
  return $secrets
}

# 辅助函数：快速解锁并设置 Session
def bw-unlock [] {
  let token = (^bw unlock --raw)
  $env.BW_SESSION = $token
  print "✅ Bitwarden unlocked."
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

def voice [] {
  if (which whisper-typist | is-empty) { print "whisper-typist not installed"; return }
  ^whisper-typist
}
