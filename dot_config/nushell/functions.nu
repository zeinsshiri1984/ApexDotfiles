# cli分流mihomo服务
def-env proxy_on [] {
    let port = 7890
    let host = "127.0.0.1"

    # 检查 mihomo 是否在监听端口
    let listening = (
        try {
            ss -lnt | lines | any { |l| $l =~ $":$port " }
        } catch {
            false
        }
    )

    if not $listening {
        error make {
            msg: $"mihomo not listening on port ($port), proxy NOT enabled"
        }
    }

    $env.http_proxy  = $"http://($host):($port)"
    $env.https_proxy = $"http://($host):($port)"
    $env.all_proxy   = $"socks5://($host):($port)"
    $env.no_proxy    = "localhost,127.0.0.1,::1,.local,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12"
}

# cli停止分流mihomo服务
def-env proxy_off [] {
    hide-env http_proxy https_proxy all_proxy no_proxy
}

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