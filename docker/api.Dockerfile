# ─── Build stage ────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder
WORKDIR /app

# Copy workspace manifests first — layer cache busts only on dependency changes
COPY package.json package-lock.json turbo.json tsconfig.base.json ./
COPY apps/api/package.json ./apps/api/
COPY packages/types/package.json ./packages/types/
COPY prisma/ ./prisma/

RUN npm ci --workspace=@internal/api --workspace=@internal/types --include-workspace-root

COPY apps/api/ ./apps/api/
COPY packages/types/ ./packages/types/

RUN npx prisma generate --schema=./prisma/schema.prisma
RUN npm run build --workspace=@internal/api

# ─── Runtime stage ───────────────────────────────────────────────────────────
FROM node:22-alpine AS runtime
WORKDIR /app

ENV NODE_ENV=production

# Copy only what the runtime needs
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/api/dist ./apps/api/dist
COPY --from=builder /app/apps/api/package.json ./apps/api/
COPY --from=builder /app/prisma ./prisma
# prisma.config.ts is required by prisma migrate deploy in v7 to resolve DATABASE_URL
COPY prisma.config.ts ./
COPY scripts/docker-entrypoint-api.sh ./

RUN chmod +x docker-entrypoint-api.sh

EXPOSE 3001
CMD ["./docker-entrypoint-api.sh"]
