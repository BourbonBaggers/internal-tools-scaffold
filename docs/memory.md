# Project Memory

> Auto-updated by `scripts/update-memory.sh` on every git commit.
> **Claude: read this file at the start of every session before doing anything else.**
> Then read `docs/researcher.md` and `docs/plans/active-plan.md`.

## Last Updated
2026-06-12T18:31:34Z

## Current Branch
`main`

## Recent Commits (last 5)
```
9e9ad46 docs: refresh memory and researcher
304facc docs: refresh memory and researcher
1c8a491 chore: make scaffold portable for any machine
b380507 plan: checkpoint
cd59a1f plan: checkpoint
```

## Active Plan Milestone Reference
Plan: `docs/plans/active-plan.md`
Current milestone: (no milestones found)

## Last Modified Files (previous commit)
```
.claude/commands/deploy.md
.claude/commands/new-tool.md
.claude/commands/status.md
.claude/settings.json
CLAUDE.md
docs/decisions.md
docs/memory.md
docs/researcher.md
docs/runbook.md
scripts/deploy.sh
scripts/new-tool.sh
scripts/setup.sh
tests/api/errors.test.ts
tests/api/health.test.ts
tests/helpers/app.ts
tests/helpers/env.ts
vitest.config.ts
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
