import type { Template } from "aws-cdk-lib/assertions";

// Questions the infra tests ask of a synthesized stack, so the tests read as
// what's deployed rather than how CloudFormation spells it.

type Resource = { Type: string; Properties: Record<string, any> };

function resourcesOf(template: Template): Record<string, Resource> {
  return template.toJSON().Resources;
}

// The user pool's pre-token trigger: its version and the function it runs.
export function preTokenTrigger(template: Template) {
  const pool = Object.values(resourcesOf(template)).find((resource) => resource.Type === "AWS::Cognito::UserPool");
  const config = pool?.Properties.LambdaConfig?.PreTokenGenerationConfig;
  return { version: config?.LambdaVersion as string | undefined, functionId: config?.LambdaArn["Fn::GetAtt"][0] as string };
}

// Every IAM action a function's role is allowed.
export function actionsAllowedFor(template: Template, functionId: string): string[] {
  const resources = resourcesOf(template);
  const roleId = resources[functionId]!.Properties.Role["Fn::GetAtt"][0];
  return Object.values(resources)
    .filter((resource) => resource.Type === "AWS::IAM::Policy")
    .filter((policy) => policy.Properties.Roles.some((role: { Ref?: string }) => role.Ref === roleId))
    .flatMap((policy) => policy.Properties.PolicyDocument.Statement)
    .flatMap((statement: { Action: string | string[] }) => [statement.Action].flat());
}

// Every API Gateway method, as "<HTTP method> <path part>" with how it's authorized.
export function apiMethods(template: Template) {
  const resources = resourcesOf(template);
  return Object.values(resources)
    .filter((resource) => resource.Type === "AWS::ApiGateway::Method")
    .map((method) => {
      const resourceId = method.Properties.ResourceId.Ref as string | undefined;
      const path = resourceId ? resources[resourceId]!.Properties.PathPart : "/";
      return {
        route: `${method.Properties.HttpMethod} ${path}`,
        needsLogin: method.Properties.AuthorizationType === "COGNITO_USER_POOLS",
      };
    });
}
