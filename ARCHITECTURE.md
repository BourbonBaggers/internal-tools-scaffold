# Architecture

This document explains what this repository is, why it is structured the way it is, and how to work within it effectively.

**Target audience:** A mid-level developer who knows React and Node.js but is new to this codebase.

---

## 1. What This Repo Is and Why It Exists

`internal-tools` is a single monorepo that consolidates all internal web tools for the business. Before this repo, tools were scattered across one-off Python scripts, standalone FastAPI apps, and vanilla HTML files with no consistent stack, no shared authentication, and no unified deployment.

This repo consolidates everything under one standard so that:

- Adding a new tool means adding a page and some routes, not bootstrapping a new project from scratch
- All tools share the same auth layer (Cloudflare Tunnel + Google SSO), the same database, and the same deployment pipeline
- One person can maintain everything without context-switching between stacks

**The guiding principle:** boring, mainstream tech. Every decision below was made by asking "what will be easiest to understand and maintain in three years by a single developer?"

---

## 2. Repository Structure

```
internal-tools/
├── apps/
│   ├── web/          React 19 + Vite 8 + Tailwind v4 + shadcn/ui (all tools in one app)
│   └── api/          Fastify 5 + Zod + Prisma 7 (single API for all tools)
├── packages/
│   └── types/        Shared TypeScript interfaces (API contracts, used by both apps)
├── prisma/           Single PostgreSQL schema + migration history
├── docker/           Dockerfiles + nginx config
├── docs/
│   ├── memory.md     Auto-updated session context (read at session start)
│   ├── researcher.md Auto-updated codebase index (models, routes, pages)
│   └── plans/        Active and completed work plans with milestones
├── tests/api/        Fastify integration tests (fastify.inject() — no server needed)
├── scripts/          deploy.sh, backup-db.sh, update-memory.sh, etc.
├── .claude/          Claude Code settings and hooks
├── .husky/           Git pre-commit quality gates
├── CLAUDE.md         Claude working instructions
└── ARCHITECTURE.md   This file
```

---

## 3. Stack Decisions and Why

| Layer              | Choice                                    | Why                                                                                                                      |
| ------------------ | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Frontend framework | React 19 + Vite 8                         | React for ecosystem depth; Vite for fast dev without Next.js SSR overhead (not needed for internal tools)                |
| UI components      | shadcn/ui + Tailwind v4                   | Copy-paste components you own and can modify. No version-lock to a component library. Tailwind v4 uses CSS-first config. |
| Type safety        | TypeScript strict mode + `packages/types` | Shared types enforce the API contract at compile time in both frontend and backend                                       |
| Backend framework  | Fastify 5                                 | Fastest Node HTTP framework; first-class TypeScript; schema validation built-in; excellent plugin architecture           |
| ORM                | Prisma 7                                  | Best-in-class DX for PostgreSQL + TypeScript; migration history in version control; readable query API                   |
| Validation         | Zod 4                                     | Single validation library used everywhere: API inputs, env vars, form schemas, shared types                              |
| Database           | PostgreSQL 17                             | Reliable, well-understood, ACID, supports JSON columns if needed. Runs well in Docker.                                   |
| Monorepo           | Turborepo                                 | Simple pipeline caching; handles workspaces with minimal config; faster builds than running everything sequentially      |
| Auth               | Cloudflare Tunnel + Google SSO            | Zero in-app auth code in v1. Cloudflare handles TLS, public exposure, and identity via Google SSO.                       |
| Containers         | Docker Compose                            | Right tool for a single-server homelab. Kubernetes would be operationally expensive for one developer.                   |

---

## 4. Development Workflow

### First-time setup (Mac Mini)

1. Install dependencies: `brew install gitleaks` (for git secret scanning)
2. Install Node 22: `nvm install 22 && nvm use 22` (or use `.nvmrc` automatically)
3. Clone the repo
4. `npm install` — installs all workspace dependencies and sets up Husky git hooks
   - If git commits fail with `sh: Illegal option`, run: `git config core.hooksPath .husky`
     (Husky v9 sometimes sets an incorrect hooks path on first install)
5. Copy env files: `cp .env.example .env && cp apps/api/.env.example apps/api/.env`
6. Edit `apps/api/.env` with dev values (the dev defaults work with the dev compose file)

### Daily dev workflow

```bash
# Start postgres (only service that runs in Docker during dev)
docker compose -f docker-compose.dev.yml up -d

# Start both api (port 3001) and web (port 5173) with HMR
npm run dev

# Open http://localhost:5173
```

The Vite dev server proxies `/api/*` to `localhost:3001`, so CORS isn't an issue in development.

### Database changes

```bash
# After editing prisma/schema.prisma:
npm run db:migrate -- --name describe-the-change

# Browse data in a GUI:
npm run db:studio
```

Always commit the generated migration file in `prisma/migrations/`.

### Committing

```bash
git add <files>
git commit -m "type(scope): description"
```

The pre-commit hook runs automatically: lint-staged (ESLint + Prettier), gitleaks (secret scan), and the test suite. A commit is blocked if any of these fail.

Commit types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `milestone`.

After milestone commits: `bash scripts/update-memory.sh`

### Deploying to production

```bash
bash scripts/deploy.sh
```

This script: runs tests locally → SSHes to prod → `git pull` + `docker compose up --build -d` → polls `/health` until green → sends ntfy notification.

See `.env.example` for the required `PROD_*` environment variables (set locally, never committed).

---

## 5. Environment Setup

### Mac Mini (development)

- Node 22 via nvm (`.nvmrc` at repo root)
- Docker Desktop for Mac (runs the postgres dev container)
- gitleaks (`brew install gitleaks`) for pre-commit secret scanning
- `.env` files gitignored, sourced from `.env.example`

### Ubuntu on Proxmox (production)

- Docker Engine + Docker Compose plugin
- `cloudflared` (Cloudflare Tunnel client) as a systemd service
- The tunnel routes external HTTPS → `localhost:8080` → nginx container
- No ports exposed directly to the internet
- Backup script runs as a cron job, copies dumps to Mac Mini via scp

---

## 6. Docker Compose Topology

### Production (`docker-compose.yml`)

```
Internet
  │
  ▼
Cloudflare Tunnel ──► cloudflared (systemd on Ubuntu host)
                              │
                              ▼
                       localhost:8080
                              │
                              ▼
                    ┌─── nginx:80 (port 8080:80) ───┐
                    │                               │
                    ▼                               ▼
              /api/*  →  api:3001           /*  →  web:80
              (Fastify)                    (nginx serving
                    │                      React build)
                    ▼
              postgres:5432
              (data in named volume)
```

Services and their roles:

- **postgres** — PostgreSQL 17, data in `postgres_data` named volume
- **api** — Fastify app, built from source; no external port (nginx proxies to it)
- **web** — React build served by nginx; no external port
- **nginx** — Reverse proxy; routes `/api/*` → api, `/*` → web; exposed on port 8080

### Development (`docker-compose.dev.yml`)

Only **postgres** runs in Docker (port 5432 exposed for Prisma Studio). The `api` and `web` processes run on the Mac Mini host via `npm run dev`. This avoids the macOS bind-mount performance degradation that slows hot-module reloading in Docker.

---

## 7. API Conventions

### Route structure

```
GET  /health              Liveness check — no auth, no version prefix
GET  /docs                Swagger UI — development only
/api/v1/[tool-name]/      All versioned API routes
```

### Tool route layout

Each tool is a self-contained Fastify plugin folder. `routes/v1/index.ts` is the **only** place tools are registered — one line per tool:

```
apps/api/src/routes/v1/
├── index.ts                    ← manifest: one register() per tool
└── [tool-name]/
    ├── index.ts                ← route definitions and handlers
    ├── schema.ts               ← Zod schemas (when inline schemas get long)
    └── service.ts              ← business logic (when handlers exceed ~50 lines)
```

To add a tool:

```typescript
// routes/v1/index.ts
import myToolRoutes from "./my-tool/index.js";
app.register(myToolRoutes, { prefix: "/my-tool" });
```

Route files placed directly in `routes/v1/` (not in a subfolder) are blocked by the pre-commit hook.

### Request/Response shape

All API responses use a consistent shape:

Success:

```json
{ "data": { ... } }
```

Error (from the global error handler in `apps/api/src/plugins/error-handler.ts`):

```json
{ "error": "Human-readable message", "details": { ... } }
```

Status codes: 200 success, 201 created, 204 no content, 400 validation error, 404 not found, 409 conflict, 500 server error.

### Versioning

All routes under `/api/v1/`. When a breaking change is needed, add `/api/v2/` routes alongside v1 — do not remove v1 immediately. The frontend migrates at its own pace.

### Swagger UI

Available at `/docs` in development (`NODE_ENV=development`). Disabled in production.

---

## 8. Adding a New Tool

A "tool" is a new functional area — an inventory manager, a timecard tracker, an order dashboard, etc.

### Folder structure for a new tool

```
apps/api/src/routes/v1/[tool-name]/
    index.ts          ← routes + handlers
    schema.ts         ← Zod schemas (optional)
    service.ts        ← business logic (optional)

apps/web/src/pages/[tool-name]/
    [ToolName]Page.tsx       ← list/main view
    [ToolName]Detail.tsx     ← detail view (optional)

apps/web/src/hooks/
    use-[tool-name].ts       ← TanStack Query hooks

packages/types/src/api/
    tool-name.ts             ← shared request/response types
```

### Checklist (also in CLAUDE.md)

1. Write a plan file: `docs/plans/YYYY-MM-DD-tool-name.md`, copy to `docs/plans/active-plan.md`
2. Add Prisma models to `prisma/schema.prisma`, run `npm run db:migrate -- --name tool-name`
3. Add shared types to `packages/types/src/api/tool-name.ts`, export from `packages/types/src/index.ts`
4. Create `apps/api/src/routes/v1/tool-name/index.ts`, register in `apps/api/src/routes/v1/index.ts`
5. Create `apps/web/src/pages/tool-name/ToolNamePage.tsx`
6. Add `<Route>` in `apps/web/src/App.tsx`
7. Add nav entry in `apps/web/src/components/layout/Sidebar.tsx`
8. Create `apps/web/src/hooks/use-tool-name.ts`
9. Write tests in `tests/api/v1/tool-name.test.ts` (mandatory — at minimum happy path + bad input)

### Default UI pattern

- **List view** — TanStack Table or card grid + "New [Thing]" button in top right
- **Create/Edit** — shadcn Sheet (drawer) with React Hook Form + Zod
- **Delete** — AlertDialog confirmation from row action DropdownMenu

---

## 9. Ancillary Services

These services interact with this application but are not part of this repo.

### n8n

Automation platform for workflows **between external systems**. Runs as a separate Docker service on the prod server (its own compose file).

Use n8n when: syncing Klaviyo contacts → internal DB, receiving webhooks from external services, sending scheduled reports via email, anything that requires credentials from two different external systems in one workflow.

**Do NOT put n8n workflows in this repo's codebase.** The rule: if removing n8n would break the application, that logic belongs in the application instead.

### ntfy

Self-hosted push notification service. Application code can post to ntfy's HTTP API via `apps/api/src/lib/notify.ts`:

```typescript
import { notify } from "@/lib/notify";
await notify("Deploy succeeded", "internal-tools v1.2 deployed.", 3);
```

Priority 3 = default (operational events), priority 4 = error, priority 5 = critical outage only.

**iOS app:** There are several apps named "ntfy" in the App Store. Install the official one:
- **Developer:** Philipp C. Heckel (the creator of ntfy.sh)
- **App Store ID:** 1625396347
- **Direct link:** https://apps.apple.com/us/app/ntfy/id1625396347

### Cloudflare Tunnel + Google SSO

Cloudflare handles all of:

- TLS termination
- Public exposure (no ports open on the Proxmox host's firewall)
- Identity via Google SSO (Cloudflare Access policy)

There is no application-level auth code in v1. Every request that reaches the app has already been authenticated by Cloudflare. To set up:

1. Install `cloudflared` on the prod server: `curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && dpkg -i cloudflared.deb`
2. Authenticate: `cloudflared tunnel login`
3. Create tunnel: `cloudflared tunnel create internal-tools`
4. Configure to route to `http://localhost:8080`
5. Install as systemd service: `cloudflared service install`

### Klaviyo

External email marketing platform. n8n handles data sync between Klaviyo and the internal DB. If direct Klaviyo API calls are ever needed from application code, add a thin client at `apps/api/src/lib/klaviyo.ts`.

---

## 10. Secret Management

### Philosophy

Secrets never touch version control. Ever.

### In development (Mac Mini)

`.env` files in each workspace directory, gitignored. Template: `.env.example` (placeholders only, always committed).

### In production (Ubuntu on Proxmox)

Environment variables set on the Docker host, passed to containers via the `environment:` blocks in `docker-compose.yml` which reference `${VAR}` syntax. The host's `.env` file lives at `/opt/internal-tools/.env`, owned by root, not in the repo.

To rotate a secret:

1. Update the value on the prod server
2. Restart only the affected container: `docker compose up -d --no-deps api`

### What goes in `.env.example`

Every variable the application needs, with a comment, a safe placeholder, and the expected format. Keep `.env.example` up to date — it is the source of truth for required variables. The pre-commit hook warns if a new env var is added to `apps/api/src/env.ts` without a corresponding `.env.example` entry.

---

## 11. Backup Strategy

The `scripts/backup-db.sh` script runs on the production server via cron (default: 3 AM daily). It:

1. Dumps the running postgres container with `pg_dump`
2. Compresses the dump with gzip
3. Copies the file to the Mac Mini via scp to `~/Documents/utility-backup/internal-tools/`
4. The Mac Mini syncs this directory to iCloud automatically
5. Keeps the last 7 days of local backups on the prod server, then deletes older files

Setup requirements:

- Mac Mini must have Remote Login enabled (System Settings → Sharing → Remote Login)
- Prod server SSH public key must be in Mac's `~/.ssh/authorized_keys`
- Required env vars on prod: `BACKUP_DEST_USER`, `BACKUP_DEST_HOST`, `BACKUP_DEST_PATH`
- Cron entry: `0 3 * * * /opt/internal-tools/scripts/backup-db.sh >> /var/log/backup-internal-tools.log 2>&1`

To restore from a backup:

```bash
gunzip -c backup_file.sql.gz | docker compose exec -T postgres psql -U postgres internal_tools
```
