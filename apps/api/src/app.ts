import Fastify from "fastify";
import { env } from "./env.js";
import corsPlugin from "./plugins/cors.js";
import helmetPlugin from "./plugins/helmet.js";
import rateLimitPlugin from "./plugins/rate-limit.js";
import swaggerPlugin from "./plugins/swagger.js";
import errorHandlerPlugin from "./plugins/error-handler.js";
import routes from "./routes/index.js";

export function buildApp() {
  // Build logger options separately to avoid exactOptionalPropertyTypes issues
  // with the conditional transport assignment
  const loggerOptions = {
    level: env.LOG_LEVEL,
    ...(env.NODE_ENV === "development" && {
      transport: {
        target: "pino-pretty",
        options: { translateTime: "HH:MM:ss", ignore: "pid,hostname" },
      },
    }),
  };

  const app = Fastify({ logger: loggerOptions });

  // Order matters: error handler and security plugins before routes
  app.register(errorHandlerPlugin);
  app.register(helmetPlugin);
  app.register(corsPlugin);
  app.register(rateLimitPlugin);
  app.register(swaggerPlugin);
  app.register(routes);

  return app;
}
