import { describe, expect, test } from "vitest";
import { stageNames } from "../../infra/stage.js";
import { synth } from "../support/synth.js";

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

  // Version 1, CDK's default, would silently ignore the claims the trigger
  // adds, and every request would then get 403.
  test("the pre-token trigger runs as version 2 and can only read the table", () => {
    const { template } = synth(stage);

    const [pool] = Object.values(template.findResources("AWS::Cognito::UserPool"));
    const trigger = pool!.Properties.LambdaConfig?.PreTokenGenerationConfig;
    expect(trigger?.LambdaVersion).toBe("V2_0");

    const functionId: string = trigger.LambdaArn["Fn::GetAtt"][0];
    const roleId: string = template.toJSON().Resources[functionId].Properties.Role["Fn::GetAtt"][0];
    const actions = Object.values(template.findResources("AWS::IAM::Policy"))
      .filter((policy) => policy.Properties.Roles.some((role: { Ref: string }) => role.Ref === roleId))
      .flatMap((policy) => policy.Properties.PolicyDocument.Statement)
      .flatMap((statement: { Action: string | string[] }) => [statement.Action].flat());
    expect(actions).toContain("dynamodb:GetItem");
    expect(actions.filter((action) => /Put|Update|Delete|Write/.test(action))).toEqual([]);
  });

  // API Gateway checks the ID token and passes its claims to the API. A route
  // left open would answer anyone.
  test("every API method needs a login, except the health check", () => {
    const { template } = synth(stage);

    const resources = template.toJSON().Resources as Record<string, { Type: string; Properties: Record<string, any> }>;
    const methods = Object.values(resources).filter((resource) => resource.Type === "AWS::ApiGateway::Method");
    const pathOf = (method: { Properties: Record<string, any> }) => {
      const resourceId = method.Properties.ResourceId.Ref as string | undefined;
      return resourceId ? resources[resourceId]!.Properties.PathPart : "/";
    };
    const open = methods.filter((method) => method.Properties.AuthorizationType !== "COGNITO_USER_POOLS");

    expect(open.map((method) => `${method.Properties.HttpMethod} ${pathOf(method)}`)).toEqual(["GET health"]);
    expect(methods.length).toBeGreaterThan(1);
    template.hasResourceProperties("AWS::ApiGateway::Authorizer", {
      Type: "COGNITO_USER_POOLS",
      IdentitySource: "method.request.header.Authorization",
    });
  });
});
