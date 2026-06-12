import fastifyPlugin from "fastify-plugin";
import fastifyHelmet from "@fastify/helmet";

export default fastifyPlugin(async (app) => {
  await app.register(fastifyHelmet, {
    // Allow Swagger UI's inline scripts in development
    contentSecurityPolicy: false,
  });
});
