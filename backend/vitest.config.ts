import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: [
      {
        test: {
          name: "api",
          include: ["test/api/**/*.test.ts", "test/triggers/**/*.test.ts"],
          globalSetup: ["test/support/dynamodbLocal.ts"],
        },
      },
      {
        test: {
          name: "infra",
          include: ["test/infra/**/*.test.ts"],
          testTimeout: 60_000,
        },
      },
      {
        test: {
          name: "deployed",
          include: ["test/deployed/**/*.test.ts"],
          testTimeout: 30_000,
        },
      },
    ],
  },
});
