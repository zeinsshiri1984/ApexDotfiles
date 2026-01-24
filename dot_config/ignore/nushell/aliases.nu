alias ls = eza --icons --group-directories-first
alias ll = eza -l --icons --git --group-directories-first -a
alias tree = eza --tree --icons --group-directories-first

alias cat = bat
alias grep = rg
alias find = fd

# 行业标准工具 -> Nushell 内置命令或增强工具
# Nushell 自己的 'ps'/'sys disks' 已经很强大，且返回结构化数据

# df: 使用 Nushell 的 sys disks，并简单格式化
alias df = sys disks

# du: Nushell 暂无直接等价的递归统计，使用增强工具 dust
alias du = dust

# top: 依然推荐 btop，因为它是 TUI 且 Nushell 没有内置全屏监控
alias top = btop 

alias help = tldr
alias t = tldr


alias h = hx
alias vi = hx
alias vim = hx

alias z = zellij
alias zc = zellij attach -c

alias cc = claude
alias cx = codex
# alias gm = gemini

alias jq = jq

alias curl = curlie
# alias dig = doggo
# alias trace = trip

alias ... = cd ../..
alias .... = cd ../../..
alias cls = clear
alias c = clear
alias x = exit

alias cp = cp -i
alias mv = mv -i

alias rm = trash-put
alias rl = trash-list
alias rc = trash-empty
alias rs = trash-restore
alias rmp = /bin/rm -vI

alias l = lazygit
alias g = git
alias ga = git add
alias gaa = git add --all
alias gc = git commit -m
alias gca = git commit --amend
alias gst = git status
alias gd = git diff
alias gp = git push
alias gl = git pull

alias d = docker
alias dps = docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
alias dpsa = d ps -a
alias di = d images
alias dr = d run --rm -it
alias dex = d exec -it
alias dco = docker-compose
alias dcp = docker-compose
alias dcl = d logs -f --tail 100
alias debug = docker run --rm -it --net=host alpine sh

alias sc = systemctl
alias scu = systemctl --user
alias j = just
alias dx = devbox
