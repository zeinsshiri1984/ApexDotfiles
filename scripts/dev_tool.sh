#!/bin/bash
set -e

#uv tool install aider-chat@latest --python "$(mise where python@3.12)"

# bun/pnpm都不适合全局分发cli, 全局cli的运行时在mise config固定了一个lts版本
curl -fsSL https://claude.ai/install.sh | bash
npm install -g @openai/codex

curl -fsSL https://github.com/SaladDay/cc-switch-cli/releases/latest/download/install.sh | bash