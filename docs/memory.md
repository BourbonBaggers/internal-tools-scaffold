# Project Memory

> Auto-updated by `scripts/update-memory.sh` on every git commit.
> **Claude: read this file at the start of every session before doing anything else.**
> Then read `docs/researcher.md` and `docs/plans/active-plan.md`.

## Last Updated
2026-06-12T17:39:23Z

## Current Branch
`main`

## Recent Commits (last 5)
```
c964090 scaffold: initial monorepo structure
7a1ddd8 Initial commit
```

## Active Plan Milestone Reference
Plan: `docs/plans/active-plan.md`
Current milestone: (no milestones found)

## Last Modified Files (previous commit)
```
.claude/hooks/memory-update.sh
.claude/hooks/plan-checkpoint.sh
.claude/hooks/scope-guard.sh
.claude/hooks/web-safety.sh
.claude/settings.json
.env.example
.gitignore
.gitleaks.toml
.husky/pre-commit
.nvmrc
.prettierrc
ARCHITECTURE.md
CLAUDE.md
apps/api/.env.example
apps/api/package.json
apps/api/src/app.ts
apps/api/src/env.ts
apps/api/src/index.ts
apps/api/src/lib/notify.ts
apps/api/src/lib/prisma.ts
```

## Quick Commands
```bash
docker compose -f docker-compose.dev.yml up -d   # start dev postgres
npm run dev                                       # start api + web
npm run db:migrate -- --name <desc>               # create migration
npm run db:studio                                  # open Prisma Studio
npm test                                           # run all tests
bash scripts/deploy.sh                             # deploy to production
```
