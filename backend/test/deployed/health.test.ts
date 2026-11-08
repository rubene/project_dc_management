import { readFileSync } from "node:fs";
import { expect, test } from "vitest";
import { parseStage, stackName, type Stage } from "../../infra/stage.js";
import { assertMatchesDefinition } from "../support/openapi.js";

// Runs against a deployed stage after each deploy, to confirm the real AWS
// setup works. Business rules are covered by the API tests, not here.
const stage = parseStage(process.env.STAGE ?? "dev");
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

// The API's URL ends with its "v1" stage. Without a trailing slash, a
// relative URL would replace that segment instead of adding to it.
async function getHealth() {
  const response = await fetch(new URL("health", apiUrl.endsWith("/") ? apiUrl : `${apiUrl}/`));
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
