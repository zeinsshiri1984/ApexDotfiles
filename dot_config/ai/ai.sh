#!/bin/sh
set -e

cmd="$1"
shift || true

case "$cmd" in
  ask)
    exec mods "$@"
    ;;
  complete)
    exec mods --role=completion "$@"
    ;;
  pipe)
    exec mods --pipe "$@"
    ;;
  *)
    echo "usage: ai {ask|complete|pipe} [args...]" >&2
    exit 1
    ;;
esac
