import { describe, expect, onTestFinished, test } from "vitest";
import { testApi } from "../support/api.js";
import { fixedClock } from "../support/fakeClock.js";
import { startStalledServer } from "../support/stalledServer.js";

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

  // The API Lambda times out after 10 seconds. If the database stalls, the
  // check must give up first, or API Gateway returns a 502 instead.
  test("reports the API is unavailable when the database doesn't answer in time", async () => {
    const stalledDatabase = await startStalledServer();
    onTestFinished(() => stalledDatabase.stop());
    const startedAt = Date.now();

    const response = await testApi({ dynamoEndpoint: stalledDatabase.endpoint }).get("/health");

    expect(response.status).toBe(503);
    expect(response.body).toMatchObject({ database: "unavailable" });
    expect(Date.now() - startedAt).toBeLessThan(8_000);
  }, 15_000);
});
