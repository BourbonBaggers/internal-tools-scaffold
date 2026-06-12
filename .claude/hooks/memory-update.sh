#!/usr/bin/env bash
# memory-update.sh — PostToolUse hook on Bash
# Detects when a Bash tool call ran a git commit, then triggers
# the memory update script to refresh docs/memory.md and docs/researcher.md.

PROJECT_ROOT="/home/user/internal-tools"

TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null || echo "")

if echo "$COMMAND" | grep -q "git commit"; then
  cd "$PROJECT_ROOT" || exit 0
  bash scripts/update-memory.sh 2>/dev/null || true
  if ! git diff --quiet docs/memory.md docs/researcher.md 2>/dev/null; then
    git -c user.email="noreply@anthropic.com" -c user.name="Claude" \
      add docs/memory.md docs/researcher.md
    git -c user.email="noreply@anthropic.com" -c user.name="Claude" \
      commit --no-verify --quiet -m "docs: refresh memory and researcher" 2>/dev/null || true
  fi
fi

exit 0
