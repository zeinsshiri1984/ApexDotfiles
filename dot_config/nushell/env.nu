let home = $env.HOME
$env.XDG_CONFIG_HOME = ($home | path join ".config")
$env.XDG_DATA_HOME = ($home | path join ".local" "share")
$env.XDG_CACHE_HOME = ($home | path join ".cache")
$env.XDG_STATE_HOME = ($home | path join ".local" "state")
if ($env.XDG_RUNTIME_DIR? | is-empty) {
  $env.XDG_RUNTIME_DIR = ($env.XDG_STATE_HOME | path join "runtime")
}

mkdir --parents $env.XDG_STATE_HOME $env.XDG_CACHE_HOME $env.XDG_RUNTIME_DIR

$env.EDITOR = "hx"
$env.VISUAL = "hx"
$env.LANG = "en_US.UTF-8"
$env.PAGER = "less"

$env.BAT_CONFIG_PATH = ($env.XDG_CONFIG_HOME | path join "bat" "config")
$env.YAZI_CONFIG_HOME = ($env.XDG_CONFIG_HOME | path join "yazi")
$env.LESS = "-R -F -X -i -M"
$env.LESSHISTFILE = ($env.XDG_STATE_HOME | path join "less" "history")
$env.GNUPGHOME = ($env.XDG_DATA_HOME | path join "gnupg")
$env.RIPGREP_CONFIG_PATH = ($env.XDG_CONFIG_HOME | path join "ripgrep" "config")
$env.ATUIN_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "atuin")
$env.ATUIN_NOBIND = "true"
$env.ZELLIJ_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "zellij")
$env.CARAPACE_BRIDGES = "zsh,bash,inshellisense"

$env.DEVBOX_NO_ANALYTICS = "1"
$env.MISE_DATA_DIR = ($env.XDG_DATA_HOME | path join "mise")
$env.MISE_CONFIG_DIR = ($env.XDG_CONFIG_HOME | path join "mise")
$env.MISE_CACHE_DIR = ($env.XDG_CACHE_HOME | path join "mise")

$env.CARGO_HOME = ($env.XDG_DATA_HOME | path join "cargo")
$env.RUSTUP_HOME = ($env.XDG_DATA_HOME | path join "rustup")
$env.GOPATH = ($env.XDG_DATA_HOME | path join "go")
$env.GOMODCACHE = ($env.XDG_CACHE_HOME | path join "go" "mod")
$env.NPM_CONFIG_USERCONFIG = ($env.XDG_CONFIG_HOME | path join "npm" "npmrc")
$env.NODE_REPL_HISTORY = ($env.XDG_DATA_HOME | path join "node_repl_history")
$env.IPYTHONDIR = ($env.XDG_CONFIG_HOME | path join "ipython")
$env.PYTHONSTARTUP = ($env.XDG_CONFIG_HOME | path join "python" "pythonrc")

$env.DOCKER_CONFIG = ($env.XDG_CONFIG_HOME | path join "docker")
$env.DOCKER_HOST = ("unix://" + ($env.XDG_RUNTIME_DIR | path join "podman" "podman.sock"))
$env.DOCKER_SOCK = $env.DOCKER_HOST
$env.DOCKER_CONTENT_TRUST = "0"
$env.TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = $env.DOCKER_HOST

let extra_paths = [
  ($env.HOME | path join ".local" "bin")
  ($env.CARGO_HOME | path join "bin")
  ($env.GOPATH | path join "bin")
]
$env.PATH = ($extra_paths | append ($env.PATH | split row (char esep)) | uniq)

$env.DO_NOT_TRACK = "1"

$env.FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --info=inline --border=none --margin=0 --padding=0 --prompt='› ' --pointer='-→' --marker='+' --color=bg+:-1,bg:-1,fg:#e4b781,fg+:#ffffff --color=hl:#e66533,hl+:#e66533,header:#5b858b --color=info:#5b858b,pointer:#e66533,marker:#7060eb,spinner:#5b858b"
$env.FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
$env.FZF_CTRL_T_COMMAND = $env.FZF_DEFAULT_COMMAND

carapace _carapace nushell | save -f ~/.cache/carapace/init.nu
source ~/.cache/carapace/init.nu
