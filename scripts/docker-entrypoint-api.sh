#!/bin/sh
set -eu

echo "Running Prisma migrations..."
npx prisma migrate deploy --schema=./prisma/schema.prisma

echo "Starting API server..."
exec node apps/api/dist/index.js
