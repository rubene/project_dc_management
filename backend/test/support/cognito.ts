import type { PreTokenGenerationV2TriggerEvent } from "aws-lambda";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { inject } from "vitest";
import { createPreTokenGeneration } from "../../src/preTokenGeneration.js";
import { localClient } from "./dynamodbLocal.js";
import type { Login } from "./logins.js";

type Options = {
  triggerSource?: PreTokenGenerationV2TriggerEvent["triggerSource"];
  tableName?: string;
};

// Calls the pre-token-generation trigger the way Cognito would when it issues
// a login's tokens, against DynamoDB Local, and returns the claims it adds.
export async function claimsAddedFor(login: Login, options: Options = {}) {
  const trigger = createPreTokenGeneration({
    db: DynamoDBDocumentClient.from(localClient(inject("dynamoEndpoint"))),
    tableName: options.tableName ?? inject("tableName"),
  });
  const result = await trigger(tokenGenerationEvent(login, options.triggerSource ?? "TokenGeneration_Authentication"));
  const overrides = result.response.claimsAndScopeOverrideDetails;
  return {
    idToken: overrides?.idTokenGeneration?.claimsToAddOrOverride ?? {},
    accessToken: overrides?.accessTokenGeneration?.claimsToAddOrOverride ?? {},
  };
}

function tokenGenerationEvent(
  { sub, email }: Login, triggerSource: PreTokenGenerationV2TriggerEvent["triggerSource"],
): PreTokenGenerationV2TriggerEvent {
  const event = {
    version: "2",
    triggerSource,
    region: "us-west-2",
    userPoolId: "us-west-2_test",
    userName: sub,
    callerContext: { awsSdkVersion: "test", clientId: "test-client" },
    request: {
      userAttributes: { sub, email, email_verified: "true" },
      groupConfiguration: { groupsToOverride: [], iamRolesToOverride: [] },
      scopes: ["openid", "email"],
    },
    response: { claimsAndScopeOverrideDetails: {} },
  } satisfies Omit<PreTokenGenerationV2TriggerEvent, "triggerSource"> & { triggerSource: string };
  return event as PreTokenGenerationV2TriggerEvent;
}
