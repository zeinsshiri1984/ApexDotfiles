# Nushell functions (pure, deterministic)

def mkcd [dir: string] {
  mkdir $dir
  cd $dir
}

def ai_ask [] {
  let input = (commandline)
  if ($input | str length) == 0 {
    return
  }
  let output = (do -i { ^ai ask $input } | str trim)
  if ($output | str length) > 0 {
    print $output
  }
}

def ai_complete [] {
  let input = (commandline)
  if ($input | str length) == 0 {
    return
  }
  let output = (do -i { ^ai complete $input } | str trim)
  if ($output | str length) > 0 {
    if ($output | str starts-with $input) {
      commandline edit -r $output
    } else {
      commandline edit -a $" ($output)"
    }
  }
}

def ai_fix [] {
  let last = (history | last 1 | get command | default "")
  let exit_code = ($env.LAST_EXIT_CODE? | default 0)
  let prompt = $"Command: ($last)\nExit: ($exit_code)\nReturn a fixed command only."
  let output = (do -i { ^ai fix $prompt } | str trim)
  if ($output | str length) > 0 {
    commandline edit -r $output
  }
}
