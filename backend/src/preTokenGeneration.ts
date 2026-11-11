import type { PreTokenGenerationV2TriggerEvent } from "aws-lambda";
import { GetCommand } from "@aws-sdk/lib-dynamodb";
import type { Deps } from "./app.js";
import { keys } from "./keys.js";

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

    // A1, read consistently: the app refreshes its tokens right after signing up.
    const { Item: login } = await db.send(new GetCommand({
      TableName: tableName,
      Key: keys.login(sub),
      ConsistentRead: true,
    }));
    if (typeof login?.personId !== "string") return event;

    const claims = { personId: login.personId };
    const overrides = event.response.claimsAndScopeOverrideDetails ?? {};
    event.response.claimsAndScopeOverrideDetails = {
      ...overrides,
      idTokenGeneration: {
        ...overrides.idTokenGeneration,
        claimsToAddOrOverride: { ...overrides.idTokenGeneration?.claimsToAddOrOverride, ...claims },
      },
      accessTokenGeneration: {
        ...overrides.accessTokenGeneration,
        claimsToAddOrOverride: { ...overrides.accessTokenGeneration?.claimsToAddOrOverride, ...claims },
      },
    };
    return event;
  };
}
