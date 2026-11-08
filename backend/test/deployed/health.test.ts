import { expect, test } from "vitest";
import { stage, stageUrl } from "../support/deployedStage.js";
import { assertMatchesDefinition } from "../support/openapi.js";

// Runs against a deployed stage after each deploy, to confirm the real AWS
// setup works. Business rules are covered by the API tests, not here.
async function getHealth() {
  const response = await fetch(new URL("health", stageUrl("ApiUrl")));
  return { status: response.status, body: (await response.json()) as unknown };
}

test(`the deployed ${stage} API is up and can read its database`, async () => {
  const { status, body } = await getHealth();

  assertMatchesDefinition("GET", "/health", status, body);
  expect(status).toBe(200);
  expect(body).toMatchObject({ status: "ok", database: "ok" });
});

test(`the deployed ${stage} API's clock is close to the real time`, async () => {
  const { body } = await getHealth();
  const { time } = body as { time: string };

  expect(Math.abs(Date.parse(time) - Date.now())).toBeLessThan(60_000);
});
