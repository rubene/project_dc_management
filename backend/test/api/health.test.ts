import { describe, expect, test } from "vitest";
import { testApi } from "../support/api.js";
import { fixedClock } from "../support/fakeClock.js";

describe("GET /health", () => {
  test("reports the API is up", async () => {
    const response = await testApi().get("/health");

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({ status: "ok" });
  });

  test("reports the database is reachable", async () => {
    const response = await testApi().get("/health");

    expect(response.body).toMatchObject({ database: "ok" });
  });

  test("reports the API is unavailable when it can't read the database", async () => {
    const response = await testApi({ tableName: "no-such-table" }).get("/health");

    expect(response.status).toBe(503);
    expect(response.body).toMatchObject({ status: "unavailable", database: "unavailable" });
  });

  test("reports the server's current time", async () => {
    const clock = fixedClock("2026-03-14T15:09:26.000Z");

    const response = await testApi({ clock }).get("/health");

    expect(response.body).toMatchObject({ time: "2026-03-14T15:09:26.000Z" });
  });
});
