import { describe, it, expect, beforeAll, afterAll } from "vitest";
import type { FastifyInstance } from "fastify";

process.env["DATABASE_URL"] = "postgresql://test:test@localhost:5432/test";
process.env["NODE_ENV"] = "test";

const { buildApp } = await import("../../apps/api/src/app.js");

describe("Error handling", () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = buildApp();
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it("unknown route returns 404 with error shape", async () => {
    const response = await app.inject({ method: "GET", url: "/api/v1/does-not-exist" });

    expect(response.statusCode).toBe(404);
    const body = response.json<{ error: string }>();
    expect(typeof body.error).toBe("string");
    expect(body.error.length).toBeGreaterThan(0);
  });
});
