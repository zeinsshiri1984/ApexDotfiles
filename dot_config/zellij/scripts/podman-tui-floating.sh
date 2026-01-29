#!/bin/bash
set -eo pipefail

# Podman-tui floating pane entry
# Explicitly show executed commands

exec podman-tui --show-cmd
