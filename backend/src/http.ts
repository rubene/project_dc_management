import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";

export function json(statusCode: number, body: unknown): APIGatewayProxyResult {
  return {
    statusCode,
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  };
}

// A success with nothing to return.
export function noContent(): APIGatewayProxyResult {
  return { statusCode: 204, headers: {}, body: "" };
}

// The request's JSON body, or undefined if it has none or it isn't JSON.
export function parseBody(event: APIGatewayProxyEvent): unknown {
  if (!event.body) return undefined;
  try {
    return JSON.parse(event.body);
  } catch {
    return undefined;
  }
}
