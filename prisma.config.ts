// Prisma v7 configuration — used by prisma migrate and prisma studio.
// Runtime connection is passed directly to PrismaClient (see apps/api/src/lib/prisma.ts).
import { defineConfig } from "@prisma/config";

export default defineConfig({
  datasource: {
    url: process.env["DATABASE_URL"] ?? "",
  },
});
