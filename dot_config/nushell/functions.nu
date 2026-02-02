# gitignore 生成器 (gitignore.io)
def gi [...langs: string] {
  if ($langs | is-empty) {
    print "用法: gi <list|search TERM|LANG1 LANG2...>"
    return
  }
  match $langs.0 {
    "list" => {
      http get "https://www.toptal.com/developers/gitignore/api/list" | split row ","
    }
    "search" => {
      if ($langs | length) < 2 {
        print "用法: gi search <关键词>"
        return
      }
      http get "https://www.toptal.com/developers/gitignore/api/list"
        | split row ","
        | where { $in =~ $langs.1 }
    }
    _ => {
      http get $"https://www.toptal.com/developers/gitignore/api/($langs | str join ',')"
    }
  }
}

# === AI 函数 (ShellGPT + Groq) ===

# AI Ask: 管道/附件/纯对话
# 用法: sgpt "问题" | cmd | sgpt "解释" | cat file | sgpt "分析"
# 直接使用 sgpt 原生命令，不封装

def _ai_invalid [reason: string] {
  if ($reason | is-empty) { return }
  print --stderr $reason
}

def _ai_validate_cmd [cmd: string] {
  if ($cmd | is-empty) { return false }
  if ($cmd | str contains "\n") { _ai_invalid "ai: multiline output"; return false }
  if ($cmd | str contains "&&") { _ai_invalid "ai: contains &&"; return false }
  if ($cmd | str contains ";") { _ai_invalid "ai: contains ;"; return false }
  if ($cmd | str contains "<<") { _ai_invalid "ai: contains heredoc"; return false }
  if ($cmd | str ends-with "\\") { _ai_invalid "ai: trailing \\"; return false }
  true
}

# AI 补全: 读取 command buffer + 光标位置
def ai_complete [] {
  let buffer = (commandline)
  if ($buffer | str trim | is-empty) { return }

  let cursor = (commandline get-cursor)
  let prompt = [
    "SYSTEM: 只输出单条 shell 命令，不要解释，不要多行"
    "INPUT:"
    $"BUFFER: ($buffer)"
    $"CURSOR: ($cursor)"
  ] | str join "\n"

  let result = (do -i { ^sgpt --instruct $prompt } | str trim)
  if (not (_ai_validate_cmd $result)) { return }

  commandline edit --replace $result
}

# AI Fix: 修复上一条命令
def ai_fix [] {
  let last_cmd = (history | last 1 | get command.0? | default "")
  if ($last_cmd | str trim | is-empty) {
    print --stderr "ai_fix: no last command"
    return
  }

  let exit_code = ($env.LAST_EXIT_CODE? | default 0)
  let err_text = if (($env | columns | any {|c| $c == "LAST_ERROR" })) {
    $env.LAST_ERROR | to json -r
  } else { "" }
  let shell = ($env.SHELL? | default "")
  let path = ($env.PATH? | default "")

  let prompt = [
    "SYSTEM: 只输出修复后的 shell 命令，不要解释"
    "INPUT:"
    $"CMD: ($last_cmd)"
    $"EXIT_CODE: ($exit_code)"
    $"STDERR: ($err_text)"
    $"SHELL: ($shell)"
    $"PATH: ($path)"
    $"PWD: (pwd)"
  ] | str join "\n"

  let result = (do -i { ^sgpt --instruct $prompt } | str trim)
  if (not (_ai_validate_cmd $result)) { return }

  commandline edit --replace $result
}

# AI Commit: 生成 commit message
def ai_commit [] {
  let diff = (do -i { ^git diff } | str trim)
  if ($diff | is-empty) {
    print --stderr "ai_commit: no diff"
    return
  }

  let prompt = [
    "SYSTEM: 只输出 commit message，不要解释"
    "FORMAT: subject line, blank line, body (optional)"
    "INPUT:"
    $diff
  ] | str join "\n"

  let result = (do -i { ^sgpt --instruct $prompt } | str trim)
  if ($result | is-empty) {
    print --stderr "ai_commit: empty"
    return
  }

  let lines = ($result | lines)
  let subject = ($lines | first | str trim)
  if ($subject | is-empty) {
    print --stderr "ai_commit: empty subject"
    return
  }
  let body = ($lines | skip 1 | str join "\n" | str trim)

  let subject_esc = ($subject | str replace -a '"' '\"')
  let cmd = if ($body | is-empty) {
    $"git commit -m \"($subject_esc)\""
  } else {
    let body_esc = ($body | str replace -a '"' '\"')
    $"git commit -m \"($subject_esc)\" -m \"($body_esc)\""
  }

  commandline edit --replace $cmd
}
