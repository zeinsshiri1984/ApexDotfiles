# Nushell functions (pure, deterministic)

def mkcd [dir: string] {
  mkdir $dir
  cd $dir
}
