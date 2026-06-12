import fastifyPlugin from "fastify-plugin";
import fastifySwagger from "@fastify/swagger";
import fastifySwaggerUi from "@fastify/swagger-ui";
import { env } from "../env.js";
import { jsonSchemaTransform } from "@fastify/type-provider-zod";

export default fastifyPlugin(async (app) => {
  await app.register(fastifySwagger, {
    openapi: {
      info: { title: "Internal Tools API", version: "1.0.0" },
    },
    transform: jsonSchemaTransform,
  });

  // Only expose Swagger UI in development
  if (env.NODE_ENV === "development") {
    await app.register(fastifySwaggerUi, {
      routePrefix: "/docs",
    });
  }
});
