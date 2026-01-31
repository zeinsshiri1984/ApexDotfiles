# Environment variables (single source of truth)

# Locale
export LANG=en_US.UTF-8

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_BIN_HOME="$HOME/.local/bin"

# Stable user PATH
if [ -n "$PATH" ]; then
  case ":$PATH:" in
    *":$XDG_BIN_HOME:"*) ;;
    *) PATH="$XDG_BIN_HOME:$PATH" ;;
  esac
else
  PATH="$XDG_BIN_HOME"
fi

HOMEBREW_NO_ANALYTICS=1
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  case ":$PATH:" in
    *":/home/linuxbrew/.linuxbrew/bin:"*) ;;
    *) PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH" ;;
  esac
fi

if [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  case ":$PATH:" in
    *":$HOME/.linuxbrew/bin:"*) ;;
    *) PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH" ;;
  esac
fi

XDG_AI_HOME="$XDG_CONFIG_HOME/ai"
if [ -d "$XDG_AI_HOME" ]; then
  case ":$PATH:" in
    *":$XDG_AI_HOME:"*) ;;
    *) PATH="$XDG_AI_HOME:$PATH" ;;
  esac
fi
export PATH

# Editor
export EDITOR=hx
export VISUAL=hx
