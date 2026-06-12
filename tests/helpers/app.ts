import type { FastifyInstance } from "fastify";
import { buildApp } from "../../apps/api/src/app.js";

// Shared test helper — builds and readies the Fastify app for inject() calls.
// Environment variables are set by tests/helpers/env.ts (loaded via setupFiles).
export async function buildTestApp(): Promise<FastifyInstance> {
  const app = buildApp();
  await app.ready();
  return app;
}
