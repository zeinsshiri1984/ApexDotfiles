set shell := ["bash", "-eu", "-o", "pipefail"]

default:
  @just --list  

setup:
  brew bundle --no-lock --file="$HOME/Brewfile"
  mise install
  mise reshim
  hx --grammar fetch || true
  hx --grammar build || true