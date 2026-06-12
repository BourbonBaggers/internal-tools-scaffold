# Architecture Decisions

Running log of significant technical decisions. Add an entry whenever a choice is made that a future developer (or future-you) would otherwise re-litigate.

Format: **decision → why → what was rejected and why.**

---

## ID Strategy: CUID over UUID

**Decision:** Use `@default(cuid())` for all primary keys in Prisma.

**Why:** CUIDs are URL-safe, human-readable in logs, roughly time-ordered, and have no collision risk at homelab scale. They do not leak row counts or creation timestamps the way sequential IDs do.

**Rejected:** Auto-increment integers (leak row counts, fragile in multi-source imports). UUID v4 (random, hard to read in logs, no ordering).

---

## Auth: Cloudflare Tunnel + Google SSO

**Decision:** Zero in-app authentication code. Access is controlled entirely by Cloudflare Access (Google OAuth) placed in front of the Cloudflare Tunnel.

**Why:** For a solopreneur internal tool, the complexity of session management, password hashing, and token rotation is pure overhead. Cloudflare handles it; the app trusts the tunnel.

**Rejected:** NextAuth / Lucia / hand-rolled JWT. These would add a meaningful attack surface and maintenance burden for a tool used by fewer than five people.

**Caveat:** If this tool ever needs per-user data (e.g., different users see different records), revisit. Cloudflare passes `Cf-Access-Authenticated-User-Email` in headers, which is a lightweight starting point.

---

## API Style: REST over GraphQL

**Decision:** Plain REST routes under `/api/v1/`.

**Why:** The frontend and backend are in the same repo. Shared types in `packages/types` eliminate the main benefit of GraphQL (auto-generated types). REST is easier to debug (curl, browser DevTools) and has no resolver machinery to maintain.

**Rejected:** GraphQL (overkill for CRUD tools), tRPC (adds a Zod-on-both-ends pattern that duplicates what `packages/types` already does).

---

## State Management: useState + TanStack Query only

**Decision:** No global state library. Component state with `useState`; server state with TanStack Query.

**Why:** Every tool in this repo is a CRUD interface. There is no shared client-side state that isn't derivable from server data. Adding Redux or Zustand would be a solution in search of a problem.

**Rejected:** Redux (enterprise weight, action boilerplate), Zustand (legitimate for complex local state, but that case hasn't arisen), Jotai.

---

## Infrastructure: Docker Compose over Kubernetes

**Decision:** Docker Compose on a single Mac Mini (or similar homelab machine).

**Why:** Kubernetes adds operational complexity that is not justified for a single-machine deployment. Docker Compose is understandable without platform expertise, and the entire stack fits comfortably on one machine.

**Rejected:** Kubernetes, Nomad, Fly.io (external hosting adds latency, egress cost, and a harder secret-management story for a private internal tool).

---

## Cross-Service Automation: n8n over application code

**Decision:** Data flows between external services (Klaviyo → Postgres, webhook → Slack, scheduled jobs across systems) live in n8n, a separate Docker service not in this repo.

**Why:** n8n provides a visual editor and built-in credential management for external services. Writing this in Fastify routes would require custom OAuth flows and scheduler logic for zero added benefit.

**Rejected:** Inngest, Temporal (too heavy), cron jobs inside the API container (fragile, not visible to non-developers).

**Rule:** If removing n8n would break the Fastify app, that logic has drifted into the wrong system — move it to application code.

---

## Monorepo: Turborepo

**Decision:** Single repo with `apps/api`, `apps/web`, and `packages/types`. Turborepo for task orchestration and caching.

**Why:** Shared types between API and frontend is the main win. A monorepo makes this trivial. Turborepo adds caching for builds and tests with minimal config.

**Rejected:** Separate repos (type drift, two pull request flows for every schema change), Nx (heavier config, not needed at this scale).

---

## Vite over Next.js

**Decision:** Vite for the React frontend.

**Why:** No SSR or static generation is needed — this is an authenticated internal tool behind Cloudflare Access. Next.js would add build complexity and server-side runtime for zero user-facing benefit.

**Rejected:** Next.js (SSR overhead), Create React App (deprecated).

---

## Secrets: Environment Variables over Secrets Manager

**Decision:** `.env` files on disk, never committed. Loaded by Docker Compose via `env_file`.

**Why:** A secrets manager (Vault, AWS SSM, 1Password secrets automation) adds infra complexity that is not justified for a homelab running one app. The `.env` file on the prod server is protected by OS file permissions and SSH access control.

**Revisit when:** There are multiple team members with different access levels, or compliance requirements that demand audit logs of secret access.
