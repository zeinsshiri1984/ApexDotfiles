#!/bin/sh
set -e

cmd="$1"
shift || true

notify() {
  if [ -n "${NTFY_TOPIC-}" ]; then
    printf '%s' "$1" | curl -fsS -H "Title: AI" -d @- "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 || true
  fi
}

case "$cmd" in
  ask)
    output="$(mods "$@")"
    printf '%s\n' "$output"
    notify "$output"
    ;;
  complete)
    output="$(mods --role=completion "$@")"
    printf '%s\n' "$output"
    notify "$output"
    ;;
  pipe)
    output="$(mods --pipe "$@")"
    printf '%s\n' "$output"
    notify "$output"
    ;;
  fix)
    output="$(sgpt "$@")"
    printf '%s\n' "$output"
    notify "$output"
    ;;
  *)
    echo "usage: ai {ask|complete|pipe|fix} [args...]" >&2
    exit 1
    ;;
esac
