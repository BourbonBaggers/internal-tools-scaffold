# Project Memory

> Auto-updated by `scripts/update-memory.sh` on every git commit.
> **Claude: read this file at the start of every session before doing anything else.**
> Then read `docs/researcher.md` and `docs/plans/active-plan.md`.

## Last Updated
2026-06-12T18:27:31Z

## Current Branch
`main`

## Recent Commits (last 5)
```
304facc docs: refresh memory and researcher
1c8a491 chore: make scaffold portable for any machine
b380507 plan: checkpoint
cd59a1f plan: checkpoint
c964090 scaffold: initial monorepo structure
```

## Active Plan Milestone Reference
Plan: `docs/plans/active-plan.md`
Current milestone: (no milestones found)

## Last Modified Files (previous commit)
```
docs/memory.md
docs/researcher.md
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
