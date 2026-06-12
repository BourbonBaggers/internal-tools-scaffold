import type { FastifyPluginAsync } from "fastify";
import type { HealthResponse } from "@internal/types";

const healthRoute: FastifyPluginAsync = async (app) => {
  app.get<{ Reply: HealthResponse }>(
    "/health",
    {
      schema: {
        response: {
          200: {
            type: "object",
            properties: {
              status: { type: "string", enum: ["ok"] },
              timestamp: { type: "string" },
              version: { type: "string" },
            },
            required: ["status", "timestamp", "version"],
          },
        },
      },
    },
    async () => ({
      status: "ok" as const,
      timestamp: new Date().toISOString(),
      version: process.env["npm_package_version"] ?? "unknown",
    }),
  );
};

export default healthRoute;
