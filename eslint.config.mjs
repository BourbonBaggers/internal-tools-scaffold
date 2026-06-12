import js from "@eslint/js";
import tseslint from "typescript-eslint";
import security from "eslint-plugin-security";

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  security.configs.recommended,
  {
    rules: {
      // Enforce explicit return types on exported functions
      "@typescript-eslint/explicit-module-boundary-types": "off",
      // Allow unused vars prefixed with _
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      // Prevent console.log in production code — use pino logger in API, no logging in frontend
      "no-console": ["warn", { allow: ["warn", "error"] }],
    },
  },
  {
    // Relax rules in test files
    files: ["tests/**/*.ts"],
    rules: {
      "@typescript-eslint/no-explicit-any": "off",
      "no-console": "off",
    },
  },
  {
    ignores: ["**/dist/**", "**/node_modules/**", "**/coverage/**", "prisma/migrations/**"],
  },
);
