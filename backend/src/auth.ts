import type { APIGatewayProxyEvent } from "aws-lambda";

// Who's behind a request. API Gateway's Cognito authorizer checks the token
// and passes its claims here, so the API never parses tokens itself.
// `personId` is added to the token by the pre-token-generation trigger once
// the person has signed up; before that, it's missing.
export type Login = { sub: string; email: string; personId?: string };

export function loginFrom(event: APIGatewayProxyEvent): Login | undefined {
  const claims = event.requestContext.authorizer?.claims as Record<string, string> | undefined;
  if (!claims?.sub || !claims.email) return undefined;
  return { sub: claims.sub, email: claims.email, personId: claims.personId || undefined };
}
