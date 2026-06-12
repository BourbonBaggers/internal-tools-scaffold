# Operational Runbook

Quick reference for common production problems. Each section: what you see → what to check → how to fix.

---

## App is down / 502 from Cloudflare

**Check first:**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "docker compose ps"
```

If `api` or `web` containers are not `Up`:

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "docker compose logs --tail=50 api"
```

**Common causes:**

- OOM kill → `docker stats` to check memory; restart with `docker compose up -d`
- Prisma migration failed on deploy → see "Stuck migration" below
- Port conflict → check `docker compose logs` for `EADDRINUSE`

**Restart without redeploy:**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "cd $PROD_APP_DIR && docker compose up -d"
```

---

## Rollback to a previous commit

```bash
# On the prod server:
ssh $PROD_SSH_USER@$PROD_SSH_HOST "
  cd $PROD_APP_DIR
  git log --oneline -10          # find the commit you want
  git checkout <commit-sha>
  docker compose up --build -d
"
```

To return to the main branch after rollback:

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "cd $PROD_APP_DIR && git checkout main && git pull"
```

---

## Restore from database backup

Backups are created by the `db-backup` Docker service and stored in `$PROD_APP_DIR/backups/`.

**List available backups:**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "ls -lh $PROD_APP_DIR/backups/"
```

**Restore:**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "
  cd $PROD_APP_DIR
  # Stop the API so no writes happen during restore
  docker compose stop api

  # Restore (replace FILENAME with the .sql.gz you want)
  gunzip -c backups/FILENAME.sql.gz | \
    docker compose exec -T postgres psql -U \$POSTGRES_USER \$POSTGRES_DB

  # Restart
  docker compose up -d api
"
```

---

## Rotate secrets / credentials

1. Generate new secret (password manager or `openssl rand -base64 32`)
2. Update the value in the prod `.env` file on the server:
   ```bash
   ssh $PROD_SSH_USER@$PROD_SSH_HOST "nano $PROD_APP_DIR/.env"
   ```
3. Restart the affected service:
   ```bash
   ssh $PROD_SSH_USER@$PROD_SSH_HOST "cd $PROD_APP_DIR && docker compose up -d api"
   ```
4. Revoke the old secret in the external service (Klaviyo, etc.)
5. Update the value in your local `.env` file

Never commit `.env` to git. If a secret was accidentally committed, rotate it immediately — assume it is compromised.

---

## Stuck migration (Prisma)

**Symptom:** Deploy fails with `P3009 migrate found failed migrations` or the API refuses to start.

**Check migration status:**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "cd $PROD_APP_DIR && docker compose exec api npx prisma migrate status"
```

**Resolve a failed migration:**

```bash
# Mark the failed migration as rolled back so Prisma will re-apply it
ssh $PROD_SSH_USER@$PROD_SSH_HOST "
  cd $PROD_APP_DIR
  docker compose exec api npx prisma migrate resolve --rolled-back <migration-name>
  docker compose exec api npx prisma migrate deploy
"
```

If the migration state is completely corrupted, restore from backup (see above) and re-deploy.

---

## Disk space

**Check:**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "df -h && docker system df"
```

**Reclaim Docker space (safe — only removes unused images/containers):**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "docker system prune -f"
```

**Reclaim old backups (keep the last 7):**

```bash
ssh $PROD_SSH_USER@$PROD_SSH_HOST "
  ls -t $PROD_APP_DIR/backups/*.sql.gz | tail -n +8 | xargs rm -f
"
```

---

## Logs

```bash
# Live API logs
ssh $PROD_SSH_USER@$PROD_SSH_HOST "docker compose -f $PROD_APP_DIR/docker-compose.yml logs -f api"

# All services, last 100 lines each
ssh $PROD_SSH_USER@$PROD_SSH_HOST "docker compose -f $PROD_APP_DIR/docker-compose.yml logs --tail=100"
```
