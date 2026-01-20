alias ls = eza --icons --group-directories-first
alias ll = eza -l --icons --git --group-directories-first -a
alias tree = eza --tree --icons --group-directories-first

alias cat = bat
alias grep = rg
alias find = fd

alias h = hx
alias vi = hx
alias vim = hx

alias z = zellij
alias zc = zellij attach -c

alias cc = claude
alias cx = codex
alias gm = gemini

alias top = btop
alias ps = procs
alias df = duf
alias du = dust -d 1
alias help = tldr
alias t = tldr
alias sed = sd
alias jq = jaq

alias curl = curlie
alias dig = doggo
alias trace = trip

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
