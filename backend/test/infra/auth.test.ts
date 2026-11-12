import { describe, expect, test } from "vitest";
import { stageNames } from "../../infra/stage.js";
import { synth } from "../support/synth.js";
import { actionsAllowedFor, apiMethods, preTokenTrigger } from "../support/template.js";

describe.each(stageNames)("logins in the %s stage", (stage) => {
  // MFA is optional for everyone for now (#51).
  test("people sign up and sign in with their email, and can add an authenticator app", () => {
    const { template } = synth(stage);

    template.resourceCountIs("AWS::Cognito::UserPool", 1);
    template.hasResourceProperties("AWS::Cognito::UserPool", {
      UsernameAttributes: ["email"],
      AdminCreateUserConfig: { AllowAdminCreateUserOnly: false },
      MfaConfiguration: "OPTIONAL",
      EnabledMfas: ["SOFTWARE_TOKEN_MFA"],
      // Version 2 of the pre-token trigger needs the Essentials plan.
      UserPoolTier: "ESSENTIALS",
    });
  });

  // Losing the user pool loses every login, and logins can't be moved to a
  // new pool. Dev only holds made-up data.
  test(stage === "dev"
    ? "the user pool can be deleted with the stack"
    : "the user pool is kept, and protected from deletion", () => {
    const { template } = synth(stage);

    template.hasResource("AWS::Cognito::UserPool", {
      DeletionPolicy: stage === "dev" ? "Delete" : "Retain",
      Properties: { DeletionProtection: stage === "dev" ? "INACTIVE" : "ACTIVE" },
    });
  });

  // Version 1, CDK's default, would silently ignore the claims the trigger
  // adds, and every request would then get 403.
  test("the pre-token trigger runs as version 2 and can only read the table", () => {
    const { template } = synth(stage);

    const trigger = preTokenTrigger(template);
    expect(trigger.version).toBe("V2_0");
    const actions = actionsAllowedFor(template, trigger.functionId);
    expect(actions).toContain("dynamodb:GetItem");
    expect(actions.filter((action) => /Put|Update|Delete|Write/.test(action))).toEqual([]);
  });

  // API Gateway checks the ID token and passes its claims to the API. A route
  // left open would answer anyone.
  test("every API method needs a login, except reading the health check", () => {
    const { template } = synth(stage);

    const methods = apiMethods(template);
    expect(methods.filter((method) => !method.needsLogin).map((method) => method.route)).toEqual(["GET health"]);
    // Every path and method still reaches the API, which answers the ones it
    // doesn't have with 404.
    expect(methods.filter((method) => method.needsLogin).map((method) => method.route).sort())
      .toEqual(["ANY /", "ANY health", "ANY {proxy+}"]);
    template.hasResourceProperties("AWS::ApiGateway::Authorizer", {
      Type: "COGNITO_USER_POOLS",
      IdentitySource: "method.request.header.Authorization",
    });
  });
});
