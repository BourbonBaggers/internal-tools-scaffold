// Sets required environment variables before any test module is loaded.
// Vitest runs this file first via setupFiles in vitest.config.ts.
process.env["DATABASE_URL"] = "postgresql://test:test@localhost:5432/test";
process.env["NODE_ENV"] = "test";
