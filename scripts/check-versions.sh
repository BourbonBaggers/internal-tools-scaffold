#!/usr/bin/env bash
# Checks installed dependency versions against latest published versions.
# Highlights packages where the latest major version differs from what's installed.
# Run at the start of any Claude session or before updating dependencies.
#
# Usage: bash scripts/check-versions.sh
#
# Context: Claude's training cutoff is August 2025. Major version changes
# after that date may include breaking changes or important new conventions
# that Claude is unaware of. This script surfaces those gaps.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Dependency Version Check ==="
echo "Claude training cutoff: August 2025"
echo "Check date: $(date +%Y-%m-%d)"
echo ""

# Key packages to check — add/remove as the stack evolves
KEY_PACKAGES=(
  "fastify"
  "react"
  "vite"
  "tailwindcss"
  "prisma"
  "@prisma/client"
  "zod"
  "@tanstack/react-query"
  "@tanstack/react-table"
  "typescript"
  "turbo"
  "react-router-dom"
  "@fastify/type-provider-zod"
  "lucide-react"
  "vitest"
)

MAJOR_CHANGES=0

for pkg in "${KEY_PACKAGES[@]}"; do
  # Get installed version from node_modules (may not exist yet — skip gracefully)
  INSTALLED=$(node -e "
try {
  const p = require('./node_modules/${pkg}/package.json');
  console.log(p.version);
} catch(e) {
  // Try workspace packages
  try {
    const p = require('./apps/api/node_modules/${pkg}/package.json');
    console.log(p.version);
  } catch(e2) {
    try {
      const p = require('./apps/web/node_modules/${pkg}/package.json');
      console.log(p.version);
    } catch(e3) {
      console.log('not-installed');
    }
  }
}
" 2>/dev/null || echo "not-installed")

  LATEST=$(npm info "$pkg" version 2>/dev/null || echo "unknown")

  if [[ "$INSTALLED" == "not-installed" ]]; then
    printf "  %-45s installed: %-12s latest: %s\n" "$pkg" "(not installed)" "$LATEST"
    continue
  fi

  if [[ "$LATEST" == "unknown" ]]; then
    printf "  %-45s installed: %-12s latest: (unavailable)\n" "$pkg" "$INSTALLED"
    continue
  fi

  INSTALLED_MAJOR=$(echo "$INSTALLED" | cut -d. -f1)
  LATEST_MAJOR=$(echo "$LATEST" | cut -d. -f1)

  if [[ "$INSTALLED_MAJOR" != "$LATEST_MAJOR" ]]; then
    printf "  %-45s installed: %-12s latest: %s  *** MAJOR VERSION CHANGE ***\n" "$pkg" "$INSTALLED" "$LATEST"
    MAJOR_CHANGES=$((MAJOR_CHANGES + 1))
  elif [[ "$INSTALLED" != "$LATEST" ]]; then
    printf "  %-45s installed: %-12s latest: %s\n" "$pkg" "$INSTALLED" "$LATEST"
  else
    printf "  %-45s installed: %-12s (up to date)\n" "$pkg" "$INSTALLED"
  fi
done

echo ""
if [[ $MAJOR_CHANGES -gt 0 ]]; then
  echo "⚠  $MAJOR_CHANGES package(s) have major version changes."
  echo "   Before using these packages, review their migration guides / CHANGELOG."
  echo "   Claude may be unaware of breaking changes introduced after August 2025."
  echo ""
  echo "   To check a package changelog:"
  echo "   npm info <package> repository"
  echo "   Then visit the repo's releases/CHANGELOG page."
else
  echo "All key packages are within expected major versions."
fi
