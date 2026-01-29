#!/bin/bash
set -eo pipefail

# Zellij floating pane entry for Yazi
# Context-specific: disable preview ONLY inside Zellij

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
YAZI_CONFIG_HOME="$XDG_CONFIG_HOME/yazi"

# Create a temp override config dir
TMP_YAZI_CONFIG="$(mktemp -d)"

# Copy base config if exists
if [ -d "$YAZI_CONFIG_HOME" ]; then
  cp -a "$YAZI_CONFIG_HOME/." "$TMP_YAZI_CONFIG/"
fi

# Override preview behavior for Zellij only
cat >"$TMP_YAZI_CONFIG/yazi.toml" <<'EOF'
[preview]
max_width = 0
max_height = 0
EOF

export YAZI_CONFIG_HOME="$TMP_YAZI_CONFIG"

exec yazi
