import { expect, test } from "vitest";
import { stage, stageOutput, stageUrl } from "../support/deployedStage.js";
import { assertMatchesDefinition } from "../support/openapi.js";

// Confirms the Admin web app is served through CloudFront alone, and that the
// same address reaches the API, which is how the app calls it.

test(`the deployed ${stage} Admin web app is served through CloudFront`, async () => {
  const response = await fetch(stageUrl("AdminWebUrl"));

  expect(response.status).toBe(200);
  expect(response.headers.get("content-type")).toMatch(/^text\/html/);
  expect(await response.text()).toContain("flutter_bootstrap.js");
});

test(`the deployed ${stage} Admin web app's address reaches the API`, async () => {
  const response = await fetch(new URL("v1/health", stageUrl("AdminWebUrl")));
  const body: unknown = await response.json();

  assertMatchesDefinition("GET", "/health", response.status, body);
  expect(response.status).toBe(200);
});

// The app reads it at start-up to sign in to the right user pool.
test(`the deployed ${stage} Admin web app is told the stage's user pool`, async () => {
  const response = await fetch(new URL("config.json", stageUrl("AdminWebUrl")));

  expect(response.status).toBe(200);
  expect(await response.json()).toEqual({
    region: "us-west-2",
    userPoolId: stageOutput("UserPoolId"),
    appClientId: stageOutput("AppClientId"),
  });
});

test(`the deployed ${stage} Admin web bucket refuses direct requests`, async () => {
  const response = await fetch(new URL("index.html", stageUrl("AdminWebBucketUrl")));

  expect(response.status).toBe(403);
});
