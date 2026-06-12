#!/usr/bin/env bash
# Scaffolds a new tool — creates all boilerplate files in the right locations.
# Usage: bash scripts/new-tool.sh <tool-name>
# Example: bash scripts/new-tool.sh inventory-tracker
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ─── Validate argument ────────────────────────────────────────────────────────
TOOL_NAME="${1:-}"
if [[ -z "$TOOL_NAME" ]]; then
  echo "Usage: bash scripts/new-tool.sh <tool-name>"
  echo "Example: bash scripts/new-tool.sh inventory-tracker"
  exit 1
fi

if ! echo "$TOOL_NAME" | grep -qE '^[a-z][a-z0-9]*(-[a-z][a-z0-9]*)*$'; then
  echo "ERROR: Tool name must be kebab-case (lowercase letters, numbers, hyphens only)."
  echo "  Valid:   inventory-tracker, orders, beer-log"
  echo "  Invalid: InventoryTracker, inventory_tracker, 1orders"
  exit 1
fi

if [[ -d "apps/api/src/routes/v1/${TOOL_NAME}" ]]; then
  echo "ERROR: Tool already exists at apps/api/src/routes/v1/${TOOL_NAME}/"
  exit 1
fi

# ─── Derive name variants ─────────────────────────────────────────────────────
PASCAL_NAME=$(python3 -c "print(''.join(w.capitalize() for w in '${TOOL_NAME}'.split('-')))")
CAMEL_NAME=$(python3 -c "parts='${TOOL_NAME}'.split('-'); print(parts[0]+''.join(w.capitalize() for w in parts[1:]))")
DISPLAY_NAME=$(python3 -c "print(' '.join(w.capitalize() for w in '${TOOL_NAME}'.split('-')))")

echo ""
echo "Scaffolding: ${DISPLAY_NAME}"
echo ""

# ─── API route ────────────────────────────────────────────────────────────────
mkdir -p "apps/api/src/routes/v1/${TOOL_NAME}"
cat > "apps/api/src/routes/v1/${TOOL_NAME}/index.ts" << EOF
import type { FastifyPluginAsync } from "fastify";

const routes: FastifyPluginAsync = async (app) => {
  // GET /api/v1/${TOOL_NAME}
  app.get("/", async (_request, reply) => {
    return reply.send({ data: [] });
  });
};

export default routes;
EOF
echo "  ✓ apps/api/src/routes/v1/${TOOL_NAME}/index.ts"

# ─── Frontend page ────────────────────────────────────────────────────────────
mkdir -p "apps/web/src/pages/${TOOL_NAME}"
cat > "apps/web/src/pages/${TOOL_NAME}/${PASCAL_NAME}Page.tsx" << EOF
import { PageTitle } from "@/components/shared/PageTitle";

export function ${PASCAL_NAME}Page() {
  return (
    <div className="flex flex-col gap-6">
      <PageTitle title="${DISPLAY_NAME}" description="" />
      <div className="rounded-lg border p-8 text-center text-sm text-muted-foreground">
        No data yet.
      </div>
    </div>
  );
}
EOF
echo "  ✓ apps/web/src/pages/${TOOL_NAME}/${PASCAL_NAME}Page.tsx"

# ─── TanStack Query hook ──────────────────────────────────────────────────────
cat > "apps/web/src/hooks/use-${TOOL_NAME}.ts" << EOF
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";

export function use${PASCAL_NAME}() {
  return useQuery({
    queryKey: ["${TOOL_NAME}"],
    queryFn: () => api.get<unknown[]>("/api/v1/${TOOL_NAME}"),
  });
}
EOF
echo "  ✓ apps/web/src/hooks/use-${TOOL_NAME}.ts"

# ─── Shared types ─────────────────────────────────────────────────────────────
cat > "packages/types/src/api/${TOOL_NAME}.ts" << EOF
// Shared request/response types for the ${DISPLAY_NAME} tool.
// Import in both the API route handler and the frontend hook.

export interface ${PASCAL_NAME} {
  id: string;
  createdAt: string;
  updatedAt: string;
}

export interface ${PASCAL_NAME}ListResponse {
  data: ${PASCAL_NAME}[];
}
EOF
echo "  ✓ packages/types/src/api/${TOOL_NAME}.ts"

# Auto-append export to types index
echo "export * from \"./api/${TOOL_NAME}.js\";" >> packages/types/src/index.ts
echo "  ✓ packages/types/src/index.ts  (export line appended)"

# ─── Test file ────────────────────────────────────────────────────────────────
mkdir -p "tests/api/v1"
cat > "tests/api/v1/${TOOL_NAME}.test.ts" << EOF
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import type { FastifyInstance } from "fastify";
import { buildTestApp } from "../../helpers/app.js";

// NOTE: The route must be registered in apps/api/src/routes/v1/index.ts
// before this test will pass. Run npm test after completing the manual steps.

describe("${DISPLAY_NAME} routes", () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = await buildTestApp();
  });

  afterAll(async () => {
    await app.close();
  });

  it("GET /api/v1/${TOOL_NAME} returns 200 with data array", async () => {
    const response = await app.inject({
      method: "GET",
      url: "/api/v1/${TOOL_NAME}",
    });
    expect(response.statusCode).toBe(200);
    const body = response.json<{ data: unknown[] }>();
    expect(Array.isArray(body.data)).toBe(true);
  });
});
EOF
echo "  ✓ tests/api/v1/${TOOL_NAME}.test.ts"

# ─── Print manual steps ───────────────────────────────────────────────────────
echo ""
echo "Generated 6 files. 4 manual edits required before running npm test:"
echo ""
echo "1. apps/api/src/routes/v1/index.ts — add inside the v1Routes function:"
echo "   import ${CAMEL_NAME}Routes from \"./${TOOL_NAME}/index.js\";"
echo "   app.register(${CAMEL_NAME}Routes, { prefix: \"/${TOOL_NAME}\" });"
echo ""
echo "2. apps/web/src/App.tsx — add inside <Route element={<AppShell />}>:"
echo "   import { ${PASCAL_NAME}Page } from \"@/pages/${TOOL_NAME}/${PASCAL_NAME}Page\";"
echo "   <Route path=\"${TOOL_NAME}\" element={<${PASCAL_NAME}Page />} />"
echo ""
echo "3. apps/web/src/components/layout/Sidebar.tsx — add to navItems:"
echo "   { label: \"${DISPLAY_NAME}\", href: \"/${TOOL_NAME}\", icon: /* pick from lucide-react */ },"
echo ""
echo "4. prisma/schema.prisma — add your data model, then run:"
echo "   npm run db:migrate -- --name ${TOOL_NAME}"
echo ""
echo "When all edits are done: npm test"
