#!/usr/bin/env bash
# scope-guard.sh — PreToolUse hook
# Blocks Edit/Write/Bash commands that target paths outside the project root.
# Claude Code hook protocol:
#   stdin: JSON with tool_name and tool_input
#   exit 0: allow
#   exit 2: block (with message on stdout)

PROJECT_ROOT="/home/user/internal-tools"

TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_name', ''))
" 2>/dev/null || echo "")

# ─── Edit / Write / MultiEdit ────────────────────────────────────────────────
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "MultiEdit" ]]; then
  FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
print(inp.get('file_path', '') or inp.get('path', ''))
" 2>/dev/null || echo "")

  if [[ -n "$FILE_PATH" && "$FILE_PATH" != "$PROJECT_ROOT"* ]]; then
    echo "BLOCKED: Attempted to write outside project root: $FILE_PATH"
    exit 2
  fi
fi

# ─── Bash ────────────────────────────────────────────────────────────────────
if [[ "$TOOL_NAME" == "Bash" ]]; then
  COMMAND=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null || echo "")

  # Block globally destructive commands
  DESTRUCTIVE_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \$HOME"
    "chmod -R 777 /"
    "dd if=/dev/zero"
    "mkfs."
  )
  for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qF "$pattern"; then
      echo "BLOCKED: Destructive command pattern: $pattern"
      exit 2
    fi
  done

  # Block writes redirected to system paths
  if echo "$COMMAND" | python3 -c "
import sys, re
cmd = sys.stdin.read()
if re.search(r'(tee|>>|>)\s+/(etc|usr|var|root|boot|sys|proc)', cmd):
    sys.exit(1)
" 2>/dev/null; then
    true
  else
    echo "BLOCKED: Write redirect to system path detected"
    exit 2
  fi
fi

exit 0
