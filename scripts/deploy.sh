#!/usr/bin/env bash
# Full deploy pipeline:
#   1. Run local tests
#   2. Run security audit
#   3. SSH to prod: git pull → docker compose up --build -d
#   4. Poll /health until 200 or timeout
#   5. Send ntfy notification (success or failure)
#
# Required env vars (set locally, never commit):
#   PROD_SSH_HOST, PROD_SSH_USER, PROD_APP_DIR, PROD_HEALTH_URL
#   NTFY_URL, NTFY_TOPIC (optional — skipped if not set)
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load local .env if present (for PROD_SSH_HOST etc.)
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  set -o allexport
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/.env"
  set +o allexport
fi

: "${PROD_SSH_HOST:?PROD_SSH_HOST is required}"
: "${PROD_SSH_USER:?PROD_SSH_USER is required}"
: "${PROD_APP_DIR:?PROD_APP_DIR is required}"
: "${PROD_HEALTH_URL:?PROD_HEALTH_URL is required}"

NTFY_URL="${NTFY_URL:-}"
NTFY_TOPIC="${NTFY_TOPIC:-}"

notify() {
  local title="$1" message="$2" priority="${3:-3}"
  if [[ -n "$NTFY_URL" && -n "$NTFY_TOPIC" ]]; then
    curl -s -d "$message" -H "Title: $title" -H "Priority: $priority" \
      "$NTFY_URL/$NTFY_TOPIC" >/dev/null 2>&1 || true
  fi
}

on_error() {
  echo "Deploy FAILED"
  notify "Deploy failed" "internal-tools deploy failed. Check terminal output." 4
}
trap on_error ERR

echo "==> [1/4] Running tests..."
cd "$PROJECT_ROOT"
npm test

echo "==> [2/4] Running security audit..."
bash scripts/security-check.sh

echo "==> [3/4] Deploying to $PROD_SSH_HOST..."
# shellcheck disable=SC2029
ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" "
  set -euo pipefail
  cd \"$PROD_APP_DIR\"
  git pull
  docker compose up --build -d
"

echo "==> [4/4] Waiting for health check at $PROD_HEALTH_URL..."
MAX_ATTEMPTS=20
ATTEMPT=0
until ssh "${PROD_SSH_USER}@${PROD_SSH_HOST}" "curl -sf $PROD_HEALTH_URL > /dev/null 2>&1"; do
  ATTEMPT=$((ATTEMPT + 1))
  if [[ $ATTEMPT -ge $MAX_ATTEMPTS ]]; then
    echo "Health check timed out after $((MAX_ATTEMPTS * 3))s"
    exit 1
  fi
  echo "  Waiting... ($ATTEMPT/$MAX_ATTEMPTS)"
  sleep 3
done

echo "Deploy complete."
notify "Deploy succeeded" "internal-tools deployed successfully." 3
