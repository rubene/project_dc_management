import { expect, test } from "vitest";
import { stage, stageUrl } from "../support/deployedStage.js";
import { assertMatchesDefinition } from "../support/openapi.js";

// API Gateway's Cognito authorizer turns away requests without a valid token
// before they reach the API. Only the real stage can show that it's wired up.
test(`the deployed ${stage} API refuses a request without a login`, async () => {
  const response = await fetch(new URL("me", stageUrl("ApiUrl")));
  const body: unknown = await response.json();

  expect(response.status).toBe(401);
  assertMatchesDefinition("GET", "/me", response.status, body);
});

test(`the deployed ${stage} API refuses a made-up token`, async () => {
  const response = await fetch(new URL("me", stageUrl("ApiUrl")), {
    headers: { authorization: "Bearer not-a-real-token" },
  });
  const body: unknown = await response.json();

  expect(response.status).toBe(401);
  assertMatchesDefinition("GET", "/me", response.status, body);
});
