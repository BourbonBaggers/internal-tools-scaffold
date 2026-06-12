#!/usr/bin/env bash
# plan-checkpoint.sh — PostToolUse hook
# Auto-commits docs/plans/active-plan.md after every Edit/Write to it.
# Ensures plan state is always in git even if a session dies mid-milestone.

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN_FILE="docs/plans/active-plan.md"

TOOL_INPUT=$(cat)
FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
print(inp.get('file_path', '') or inp.get('path', ''))
" 2>/dev/null || echo "")

# Only act on edits to active-plan.md
if [[ "$FILE_PATH" != *"$PLAN_FILE" ]]; then
  exit 0
fi

cd "$PROJECT_ROOT" || exit 0

# Commit if there are staged or unstaged changes to the plan file
if ! git diff --quiet "$PLAN_FILE" 2>/dev/null || git ls-files --others --exclude-standard "$PLAN_FILE" | grep -q .; then
  bash scripts/update-memory.sh 2>/dev/null || true
  git -c user.email="noreply@anthropic.com" -c user.name="Claude" \
    add "$PLAN_FILE" docs/memory.md docs/researcher.md
  git -c user.email="noreply@anthropic.com" -c user.name="Claude" \
    commit --no-verify -m "plan: checkpoint" \
    --quiet 2>/dev/null || true
fi

exit 0
