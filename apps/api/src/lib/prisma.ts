import { PrismaClient } from "@prisma/client";
import { env } from "../env.js";

// Single Prisma client instance for the process lifetime.
// Import this everywhere — do not instantiate PrismaClient directly.
// Prisma v7: datasourceUrl passed here because url is no longer in schema.prisma.
export const prisma = new PrismaClient({
  datasourceUrl: env.DATABASE_URL,
} as ConstructorParameters<typeof PrismaClient>[0]);
