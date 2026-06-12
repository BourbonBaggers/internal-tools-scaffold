# Active Plan: Initial Scaffold

## Context

Establishing the baseline monorepo scaffold and standards for all future internal tools.

## Status

**WIP — not yet a usable foundation.** This branch contains the initial scaffolding
commit but has not been end-to-end validated on a real machine. Do not build apps on
this yet.

**Milestone 1 (next)** is the version worth cloning: the scaffold runs cleanly from
a fresh clone on the Mac Mini — `npm install`, `docker compose up`, `npm run dev` all
work, `/health` responds, the frontend loads, and Husky hooks fire on commit.

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
