import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["tests/**/*.test.ts"],
    environment: "node",
    // Tests should be fast — if any exceed 5s something is wrong
    testTimeout: 5000,
  },
});
