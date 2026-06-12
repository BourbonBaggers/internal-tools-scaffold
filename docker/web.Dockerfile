# ─── Build stage ────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json turbo.json tsconfig.base.json ./
COPY apps/web/package.json ./apps/web/
COPY packages/types/package.json ./packages/types/

RUN npm ci --workspace=@internal/web --workspace=@internal/types --include-workspace-root

COPY apps/web/ ./apps/web/
COPY packages/types/ ./packages/types/

RUN npm run build --workspace=@internal/web

# ─── Runtime stage ───────────────────────────────────────────────────────────
FROM nginx:1.27-alpine AS runtime

COPY --from=builder /app/apps/web/dist /usr/share/nginx/html
COPY docker/nginx/spa.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
