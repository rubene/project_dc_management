import { readFileSync } from "node:fs";
import { expect, test } from "vitest";
import { stackName, stageNames, type Stage } from "../../infra/stage.js";
import { assertMatchesDefinition } from "../support/openapi.js";

// Runs against a deployed stage after each deploy, to confirm the real AWS
// setup works. Business rules are covered by the API tests, not here.
const stage = (process.env.STAGE ?? "dev") as Stage;
if (!stageNames.includes(stage)) throw new Error(`Unknown STAGE "${stage}"`);
const outputs = JSON.parse(
  readFileSync(new URL(`../../cdk-outputs.${stage}.json`, import.meta.url), "utf8"),
) as Record<string, { ApiUrl?: string }>;
const apiUrl = process.env.API_URL ?? outputs[stackName(stage)]?.ApiUrl;
if (!apiUrl) throw new Error(`No ApiUrl for stage "${stage}" in cdk-outputs.${stage}.json`);

test(`the deployed ${stage} API is up and can read its database`, async () => {
  const response = await fetch(new URL("health", apiUrl));
  const body: unknown = await response.json();

  assertMatchesDefinition("GET", "/health", response.status, body);
  expect(response.status).toBe(200);
  expect(body).toMatchObject({ status: "ok", database: "ok" });
});

test(`the deployed ${stage} API's clock is close to the real time`, async () => {
  const response = await fetch(new URL("health", apiUrl));
  const { time } = (await response.json()) as { time: string };

  expect(Math.abs(Date.parse(time) - Date.now())).toBeLessThan(60_000);
});
