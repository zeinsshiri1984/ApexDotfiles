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
