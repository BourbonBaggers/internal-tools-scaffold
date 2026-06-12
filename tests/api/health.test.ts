import { describe, it, expect, beforeAll, afterAll } from "vitest";
import type { FastifyInstance } from "fastify";

// Set required env vars before importing app (app reads env at module load)
process.env["DATABASE_URL"] = "postgresql://test:test@localhost:5432/test";
process.env["NODE_ENV"] = "test";

const { buildApp } = await import("../../apps/api/src/app.js");

describe("GET /health", () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = buildApp();
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it("returns 200 with correct shape", async () => {
    const response = await app.inject({ method: "GET", url: "/health" });

    expect(response.statusCode).toBe(200);
    const body = response.json<{ status: string; timestamp: string; version: string }>();
    expect(body.status).toBe("ok");
    expect(typeof body.timestamp).toBe("string");
    expect(typeof body.version).toBe("string");
  });
});
