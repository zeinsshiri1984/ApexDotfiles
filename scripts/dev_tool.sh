#!/bin/bash
set -e

uv tool install aider-chat@latest --python "$(mise where python@3.12)"

bun add -g @anthropic-ai/claude-code