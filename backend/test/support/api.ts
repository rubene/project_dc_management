import type { APIGatewayProxyEvent } from "aws-lambda";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { inject } from "vitest";
import { createApp } from "../../src/app.js";
import { fixedClock } from "./fakeClock.js";
import { localClient } from "./dynamodbLocal.js";
import { assertMatchesDefinition, isDocumented } from "./openapi.js";
import type { Clock } from "../../src/clock.js";

type Options = { clock?: Clock; tableName?: string };

// Calls the real API handler in-process, the way API Gateway would, against
// DynamoDB Local. Documented responses are checked against the OpenAPI
// definition.
export function testApi(options: Options = {}) {
  const app = createApp({
    clock: options.clock ?? fixedClock("2026-01-01T00:00:00.000Z"),
    db: DynamoDBDocumentClient.from(localClient(inject("dynamoEndpoint"))),
    tableName: options.tableName ?? inject("tableName"),
  });

  async function request(method: string, path: string) {
    const response = await app(proxyEvent(method, path));
    const body: unknown = response.body ? JSON.parse(response.body) : undefined;
    if (isDocumented(method, path)) {
      assertMatchesDefinition(method, path, response.statusCode, body);
    }
    return { status: response.statusCode, body };
  }

  return {
    get: (path: string) => request("GET", path),
  };
}

function proxyEvent(method: string, path: string): APIGatewayProxyEvent {
  return {
    httpMethod: method,
    path,
    resource: "/{proxy+}",
    headers: {},
    multiValueHeaders: {},
    queryStringParameters: null,
    multiValueQueryStringParameters: null,
    pathParameters: { proxy: path.slice(1) },
    stageVariables: null,
    body: null,
    isBase64Encoded: false,
    requestContext: {} as APIGatewayProxyEvent["requestContext"],
  };
}
