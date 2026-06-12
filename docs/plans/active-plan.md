# Active Plan: Initial Scaffold

## Context

Establishing the baseline monorepo scaffold and standards for all future internal tools.

## Status

**Scaffold complete and validated.** `npm install` runs clean on Mac Mini, both tests
pass without a database, and Husky hooks fire on commit. `.claude/settings.json` and
all four `.claude/hooks/` scripts now use portable paths (dynamic git root, not
hardcoded to a specific machine).

This repo is published as a public GitHub template at `BourbonBaggers/internal-tools-scaffold`.
The working repo for actual tool development is `BourbonBaggers/internal-tools`.

---

## [DONE] Milestone 1: Root scaffold and shared packages

Root config files, packages/types, Prisma schema, Claude Code hooks, git quality gates.

## [DONE] Milestone 2: API application

Fastify app with plugins, health route, error handler, env validation.

## [DONE] Milestone 3: Frontend application

React + Vite + Tailwind + shadcn/ui, AppShell layout, Dashboard page, mobile-first design.

## [DONE] Milestone 4: Docker and deployment

docker-compose.yml, Dockerfiles, nginx config, deploy.sh, backup-db.sh.

## [DONE] Milestone 5: Documentation

CLAUDE.md, ARCHITECTURE.md, memory.md, researcher.md.

---

## Next Steps

When building the first real tool, replace this file with:
`docs/plans/YYYY-MM-DD-tool-name.md`
