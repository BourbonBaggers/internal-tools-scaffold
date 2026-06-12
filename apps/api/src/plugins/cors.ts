import fastifyPlugin from "fastify-plugin";
import fastifyCors from "@fastify/cors";
import { env } from "../env.js";

export default fastifyPlugin(async (app) => {
  await app.register(fastifyCors, {
    origin: env.CORS_ORIGIN,
    credentials: true,
  });
});
