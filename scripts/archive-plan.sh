#!/usr/bin/env bash
# Archives the current active plan to docs/plans/archive/ with a timestamp.
# Run this when a plan is complete and you are starting a new one.
#
# Usage:
#   bash scripts/archive-plan.sh
#   bash scripts/archive-plan.sh "plan-name-override"
#
# The archived filename format: YYYY-MM-DD-HH-MM-plan-name.md
# The plan name is extracted from the first H1 heading in active-plan.md,
# or can be passed as an argument.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_PLAN="$PROJECT_ROOT/docs/plans/active-plan.md"
ARCHIVE_DIR="$PROJECT_ROOT/docs/plans/archive"

if [[ ! -f "$ACTIVE_PLAN" ]]; then
  echo "No active-plan.md found at $ACTIVE_PLAN"
  exit 1
fi

# Derive archive filename
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")

if [[ -n "${1:-}" ]]; then
  PLAN_SLUG="$1"
else
  # Extract plan name from first H1 in the file, lowercase + hyphenate
  PLAN_SLUG=$(grep -m1 "^# " "$ACTIVE_PLAN" | sed 's/^# //' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' || echo "plan")
fi

ARCHIVE_FILE="$ARCHIVE_DIR/${TIMESTAMP}-${PLAN_SLUG}.md"

mkdir -p "$ARCHIVE_DIR"
cp "$ACTIVE_PLAN" "$ARCHIVE_FILE"

echo "Archived active plan to: docs/plans/archive/${TIMESTAMP}-${PLAN_SLUG}.md"
echo ""
echo "Next steps:"
echo "  1. Write your new plan file: docs/plans/YYYY-MM-DD-new-plan-name.md"
echo "  2. Replace docs/plans/active-plan.md with the new plan content"
echo "  3. Run: bash scripts/update-memory.sh"
