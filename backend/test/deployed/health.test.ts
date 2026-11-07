import { readFileSync } from "node:fs";
import { expect, test } from "vitest";
import { stackName, stageNames, type Stage } from "../../infra/stage.js";
import { assertMatchesDefinition } from "../support/openapi.js";

// Runs against a deployed stage after each deploy, to confirm the real AWS
// setup works. Business rules are covered by the API tests, not here.
const stage = (process.env.STAGE ?? "dev") as Stage;
if (!stageNames.includes(stage)) throw new Error(`Unknown STAGE "${stage}"`);
const apiUrl = process.env.API_URL ?? apiUrlFromCdkOutputs(stage);

// The URL the last deploy from this machine wrote. A fresh checkout or a CI
// job checking an existing deployment passes API_URL instead.
function apiUrlFromCdkOutputs(stage: Stage) {
  const file = `cdk-outputs.${stage}.json`;
  let outputs: Record<string, { ApiUrl?: string }>;
  try {
    outputs = JSON.parse(readFileSync(new URL(`../../${file}`, import.meta.url), "utf8"));
  } catch (error) {
    throw new Error(`Can't read ${file}. Deploy first, or set API_URL.`, { cause: error });
  }
  const url = outputs[stackName(stage)]?.ApiUrl;
  if (!url) throw new Error(`No ApiUrl for stage "${stage}" in ${file}. Deploy again, or set API_URL.`);
  return url;
}

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
