#!/usr/bin/env bash
# Run before deploying to production.
# Checks for known vulnerabilities in npm dependencies.
set -euo pipefail

echo "Running npm audit (high severity and above)..."
npm audit --audit-level=high

echo "Security check passed."
