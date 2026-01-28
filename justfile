set shell := ["bash", "-euo", "pipefail", "-c"]

default:
  @just --list

# Phase 1 entry
bootstrap:
  @scripts/bootstrap.sh

apply:
  @chezmoi apply --verbose

diff:
  @chezmoi diff

doctor:
  @scripts/doctor.sh

update:
  @chezmoi update --verbose
  @chezmoi apply --verbose

clean:
  @echo "No-op for now (reserved)."
