#!/usr/bin/env bash
set -euo pipefail

src="${1:-README.md}"
if [ ! -f "$src" ]; then
  echo "missing source: $src" >&2
  exit 1
fi

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "GEMINI_API_KEY missing, skip translation"
  exit 0
fi

model="${GEMINI_MODEL:-gemini-2.0-flash}"
api_url="https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}"

nav_end="$(awk '/<\/div>/{print NR; exit}' "$src")"
if [ -z "$nav_end" ]; then
  echo "nav block not found" >&2
  exit 1
fi

nav="$(sed -n "1,${nav_end}p" "$src")"
body="$(sed -n "$((nav_end+1)),\$p" "$src")"

translate() {
  local target="$1"
  local text="$2"
  local prompt
  prompt="$(cat <<EOF
Translate the following Markdown from Simplified Chinese to ${target}.
Requirements:
- Keep Markdown structure and headings unchanged.
- Do not translate code blocks or inline code.
- Keep URLs unchanged.
- Return only the translated Markdown.

${text}
EOF
)"

  local payload
  payload="$(python - <<'PY' <<<"$prompt"
import json, os, sys
prompt = sys.stdin.read()
payload = {
  "contents": [{
    "role": "user",
    "parts": [{"text": prompt}]
  }],
  "generationConfig": {
    "temperature": 0.2
  }
}
print(json.dumps(payload))
PY
)"

  local response
  response="$(curl -fsS -H "Content-Type: application/json" -d "$payload" "$api_url")"
  python - <<'PY' <<<"$response"
import json, sys
data = json.load(sys.stdin)
print(data["candidates"][0]["content"]["parts"][0]["text"])
PY
}

targets=(
  "en:English"
  "zh-TW:Traditional Chinese"
  "ja:Japanese"
  "ko:Korean"
  "de:German"
  "fr:French"
  "es:Spanish"
  "ru:Russian"
)

for item in "${targets[@]}"; do
  lang="${item%%:*}"
  target="${item#*:}"
  out="README.${lang}.md"
  translated="$(translate "$target" "$body")"
  printf "%s\n\n%s\n" "$nav" "$translated" > "$out"
done
