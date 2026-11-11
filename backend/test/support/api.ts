import type { APIGatewayProxyEvent } from "aws-lambda";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { inject } from "vitest";
import { createApp } from "../../src/app.js";
import { fixedClock } from "./fakeClock.js";
import { localClient } from "./dynamodbLocal.js";
import { assertMatchesDefinition } from "./openapi.js";
import type { Clock } from "../../src/clock.js";
import type { Login } from "./logins.js";

export type TestApi = ReturnType<typeof testApi>;

type Options = { clock?: Clock; tableName?: string; dynamoEndpoint?: string };

// Calls the real API handler in-process, the way API Gateway would, against
// DynamoDB Local. Every response is checked against the OpenAPI definition.
// `as(login)` sends requests with that login's token claims.
export function testApi(options: Options = {}, login?: Login) {
  const app = createApp({
    clock: options.clock ?? fixedClock("2026-01-01T00:00:00.000Z"),
    db: DynamoDBDocumentClient.from(localClient(options.dynamoEndpoint ?? inject("dynamoEndpoint"))),
    tableName: options.tableName ?? inject("tableName"),
  });

  async function request(method: string, path: string, requestBody?: unknown) {
    const response = await app(proxyEvent(method, path, requestBody, login));
    const body: unknown = response.body ? JSON.parse(response.body) : undefined;
    assertMatchesDefinition(method, path, response.statusCode, body);
    return { status: response.statusCode, body };
  }

  return {
    get: (path: string) => request("GET", path),
    put: (path: string, body: unknown) => request("PUT", path, body),
    post: (path: string, body: unknown) => request("POST", path, body),
    patch: (path: string, body: unknown) => request("PATCH", path, body),
    as: (login: Login) => testApi(options, login),
  };
}

function proxyEvent(method: string, path: string, body: unknown, login?: Login): APIGatewayProxyEvent {
  return {
    httpMethod: method,
    path,
    resource: "/{proxy+}",
    headers: body === undefined ? {} : { "content-type": "application/json" },
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: { proxy: path.slice(1) },
    stageVariables: null,
    body: body === undefined ? null : JSON.stringify(body),
    isBase64Encoded: false,
    requestContext: {
      authorizer: login ? { claims: { ...login } } : null,
    } as APIGatewayProxyEvent["requestContext"],
  };
}
