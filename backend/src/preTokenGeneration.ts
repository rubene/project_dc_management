import type { PreTokenGenerationV2TriggerEvent } from "aws-lambda";
import { GetCommand } from "@aws-sdk/lib-dynamodb";
import type { Deps } from "./app.js";
import { keys } from "./keys.js";

// Cognito waits about 5 seconds for the trigger, so the read gives up first.
const databaseDeadlineMs = 3_000;

type TokenGeneration = { claimsToAddOrOverride?: Record<string, string> };

// Cognito's pre-token-generation trigger (V2). Runs whenever Cognito issues a
// login's tokens, including on refresh. Once the login has signed up
// (PUT /me), it adds the person ID to the ID and access tokens, so the API
// knows the person without reading LOGIN#<sub> on every request
// (docs/data-model.md). Roles are never put in tokens; the API reads them
// from DynamoDB on each request.
export function createPreTokenGeneration({ db, tableName }: Pick<Deps, "db" | "tableName">) {
  return async (event: PreTokenGenerationV2TriggerEvent): Promise<PreTokenGenerationV2TriggerEvent> => {
    const { sub } = event.request.userAttributes;
    if (!sub) return event;

    let personId: unknown;
    try {
      // A1, read consistently: the app refreshes its tokens right after signing up.
      const { Item: login } = await db.send(new GetCommand({
        TableName: tableName,
        Key: keys.login(sub),
        ConsistentRead: true,
      }), { abortSignal: AbortSignal.timeout(databaseDeadlineMs) });
      personId = login?.personId;
    } catch (error) {
      // An error here would make Cognito refuse the login itself. Without the
      // claim the API answers 403, and the next refresh adds it.
      console.error("Couldn't read the login's person, so the tokens go without it", {
        trigger: "preTokenGeneration", error,
      });
      return event;
    }
    if (typeof personId !== "string") return event;

    const claims = { personId };
    const overrides = event.response.claimsAndScopeOverrideDetails ?? {};
    event.response.claimsAndScopeOverrideDetails = {
      ...overrides,
      idTokenGeneration: withClaims(overrides.idTokenGeneration, claims),
      accessTokenGeneration: withClaims(overrides.accessTokenGeneration, claims),
    };
    return event;
  };
}

// A token's overrides with `claims` added, keeping any already there.
function withClaims<T extends TokenGeneration>(generation: T | undefined, claims: Record<string, string>) {
  return { ...generation, claimsToAddOrOverride: { ...generation?.claimsToAddOrOverride, ...claims } };
}
