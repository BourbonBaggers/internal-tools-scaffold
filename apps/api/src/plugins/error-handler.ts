import fastifyPlugin from "fastify-plugin";
import { PrismaClientKnownRequestError } from "@prisma/client-runtime-utils";
import { ZodError } from "zod";
import { env } from "../env.js";

// Centralizes all error responses into a consistent shape:
// { error: string, details?: unknown }
// Register this before routes so all route errors flow through it.
export default fastifyPlugin(async (app) => {
  // Fastify v5 types setErrorHandler error as unknown by default — we handle all cases explicitly
  app.setErrorHandler((rawError, _request, reply) => {
    const error = rawError as Error;

    // Zod validation errors from @fastify/type-provider-zod → 400
    if (error instanceof ZodError) {
      return reply.status(400).send({
        error: "Validation error",
        details: error.flatten().fieldErrors,
      });
    }

    // Prisma unique constraint violation → 409
    if (error instanceof PrismaClientKnownRequestError && error.code === "P2002") {
      return reply.status(409).send({ error: "A record with those values already exists" });
    }

    // Prisma record not found → 404
    if (error instanceof PrismaClientKnownRequestError && error.code === "P2025") {
      return reply.status(404).send({ error: "Record not found" });
    }

    // Fastify validation / known HTTP errors → pass through status code
    // Cast separately here to avoid union type issues from Prisma instanceof narrowing above
    const httpError = error as Error & { statusCode?: number };
    if (
      typeof httpError.statusCode === "number" &&
      httpError.statusCode >= 400 &&
      httpError.statusCode < 500
    ) {
      return reply.status(httpError.statusCode).send({ error: error.message });
    }

    // All other errors → 500
    // Strip internal details in production to avoid leaking stack traces
    app.log.error(error);
    const message =
      env.NODE_ENV === "production" ? "Internal server error" : (error.message ?? "Unknown error");
    return reply.status(500).send({ error: message });
  });

  app.setNotFoundHandler((_request, reply) => {
    reply.status(404).send({ error: "Route not found" });
  });
});
