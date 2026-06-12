import type { FastifyPluginAsync } from "fastify";
import healthRoute from "./health.js";
import v1Routes from "./v1/index.js";

const routes: FastifyPluginAsync = async (app) => {
  app.register(healthRoute);
  app.register(v1Routes, { prefix: "/api/v1" });
};

export default routes;
