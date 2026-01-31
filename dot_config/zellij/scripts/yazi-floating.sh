#!/bin/bash
set -eo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
YAZI_CONFIG_HOME="$XDG_CONFIG_HOME/yazi"

TMP_YAZI_CONFIG="$(mktemp -d)"

if [ -d "$YAZI_CONFIG_HOME" ]; then
  cp -a "$YAZI_CONFIG_HOME/." "$TMP_YAZI_CONFIG/"
fi

YAZI_TOML="$TMP_YAZI_CONFIG/yazi.toml"
if [ -f "$YAZI_TOML" ]; then
  awk '
    BEGIN { skip = 0 }
    /^\[preview\]/ { skip = 1; next }
    /^\[.*\]/ { if (skip) { skip = 0 } }
    skip == 0 { print }
  ' "$YAZI_TOML" > "$YAZI_TOML.tmp"
  mv "$YAZI_TOML.tmp" "$YAZI_TOML"
else
  : > "$YAZI_TOML"
fi

cat >>"$YAZI_TOML" <<'EOF'
[preview]
max_width = 0
max_height = 0
EOF

export YAZI_CONFIG_HOME="$TMP_YAZI_CONFIG"

exec yazi
