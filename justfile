set shell := ["bash", "-eu", "-o", "pipefail"]

default:
  @just --list

bootstrap-tools:
  @echo "==> Installing global CLI tools via Homebrew"
  brew bundle --no-lock --file="$HOME/Brewfile"

setup:
  @echo "==> Installing runtimes via mise"
  mise install