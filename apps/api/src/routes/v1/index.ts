import type { FastifyPluginAsync } from "fastify";

// ─── Tool Route Registry ──────────────────────────────────────────────────────
// One register() call per tool. Each tool lives in its own subfolder:
//   routes/v1/[tool-name]/index.ts   ← route definitions
//   routes/v1/[tool-name]/schema.ts  ← Zod schemas (optional, for larger tools)
//   routes/v1/[tool-name]/service.ts ← business logic (optional, extract when handlers exceed ~50 lines)
//
// To add a tool:
//   import myToolRoutes from "./my-tool/index.js";
//   app.register(myToolRoutes, { prefix: "/my-tool" });
// ─────────────────────────────────────────────────────────────────────────────

const v1Routes: FastifyPluginAsync = async (_app) => {
  // Tools registered here as they are built
};

export default v1Routes;
