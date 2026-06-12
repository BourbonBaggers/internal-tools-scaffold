import fastifyPlugin from "fastify-plugin";
import fastifyRateLimit from "@fastify/rate-limit";

export default fastifyPlugin(async (app) => {
  await app.register(fastifyRateLimit, {
    max: 200,
    timeWindow: "1 minute",
  });
});
