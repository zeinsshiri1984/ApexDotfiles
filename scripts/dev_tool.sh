#!/bin/bash
set -e

#uv tool install aider-chat@latest --python "$(mise where python@3.12)"

# bun/pnpm都不适合全局分发cli, 全局cli的运行时在mise config固定了一个lts版本
npm install -g @anthropic-ai/claude-code
npm install -g @openai/codex