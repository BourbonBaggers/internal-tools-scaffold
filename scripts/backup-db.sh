#!/usr/bin/env bash
# Database backup script — run on the PRODUCTION SERVER via cron.
# Dumps the running postgres container, compresses it, and copies it
# to the dev Mac via scp for iCloud-backed offsite storage.
#
# Setup on prod server:
#   1. Set environment variables below (add to /etc/environment or ~/.bashrc)
#   2. Ensure prod server SSH key is in Mac's ~/.ssh/authorized_keys
#   3. Enable Remote Login on Mac: System Settings → Sharing → Remote Login
#   4. Add cron: 0 3 * * * /opt/internal-tools/scripts/backup-db.sh >> /var/log/backup-internal-tools.log 2>&1
#
# Required env vars (set on prod server, never committed):
#   POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB  (from docker-compose env)
#   BACKUP_DEST_USER    SSH username on Mac Mini
#   BACKUP_DEST_HOST    Mac Mini hostname or LAN IP (e.g., mac-mini.local)
#   BACKUP_DEST_PATH    e.g., /Users/you/Documents/utility-backup/internal-tools
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${BACKUP_DEST_USER:?BACKUP_DEST_USER is required}"
: "${BACKUP_DEST_HOST:?BACKUP_DEST_HOST is required}"
: "${BACKUP_DEST_PATH:?BACKUP_DEST_PATH is required}"

NTFY_URL="${NTFY_URL:-}"
NTFY_TOPIC="${NTFY_TOPIC:-}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${POSTGRES_DB}_${TIMESTAMP}.sql.gz"
LOCAL_BACKUP_DIR="/tmp/db-backups"
LOCAL_FILE="$LOCAL_BACKUP_DIR/$FILENAME"

notify() {
  local title="$1" message="$2" priority="${3:-3}"
  if [[ -n "$NTFY_URL" && -n "$NTFY_TOPIC" ]]; then
    curl -s -d "$message" -H "Title: $title" -H "Priority: $priority" \
      "$NTFY_URL/$NTFY_TOPIC" >/dev/null 2>&1 || true
  fi
}

mkdir -p "$LOCAL_BACKUP_DIR"

echo "[$TIMESTAMP] Dumping database $POSTGRES_DB..."
cd "$PROJECT_ROOT"
PGPASSWORD="$POSTGRES_PASSWORD" docker compose exec -T postgres \
  pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$LOCAL_FILE"

echo "Copying to $BACKUP_DEST_HOST:$BACKUP_DEST_PATH/$FILENAME..."
ssh "${BACKUP_DEST_USER}@${BACKUP_DEST_HOST}" "mkdir -p '$BACKUP_DEST_PATH'"
scp "$LOCAL_FILE" "${BACKUP_DEST_USER}@${BACKUP_DEST_HOST}:${BACKUP_DEST_PATH}/${FILENAME}"

# Keep last 7 days locally on prod, clean up older files
find "$LOCAL_BACKUP_DIR" -name "${POSTGRES_DB}_*.sql.gz" -mtime +7 -delete

echo "Backup complete: $FILENAME"
notify "Backup complete" "DB backup $FILENAME copied to Mac." 3
