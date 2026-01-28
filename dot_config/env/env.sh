# Environment variables (single source of truth)

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"

# Stable user PATH
case ":$PATH:" in
  *":$XDG_BIN_HOME:"*) ;;
  *) PATH="$XDG_BIN_HOME:$PATH" ;;
esac
export PATH

# Editor
export EDITOR=hx
export VISUAL=hx
