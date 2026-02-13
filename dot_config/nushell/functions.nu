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

def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")

    yazi ...$args --cwd-file $tmp

    if ($tmp | path exists) {
        let cwd = (open $tmp | str trim)

        if $cwd != "" and $cwd != $env.PWD {
            cd $cwd
        }

        ^rm -f $tmp
    }
}