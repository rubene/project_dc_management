import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import type { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import type { Clock } from "./clock.js";
import { getHealth } from "./health.js";
import { json } from "./http.js";

export type Deps = {
  clock: Clock;
  db: DynamoDBDocumentClient;
  tableName: string;
};

type Route = (deps: Deps) => Promise<APIGatewayProxyResult>;

const routes: Record<string, Route> = {
  "GET /health": getHealth,
};

// The whole API behind one Lambda. API Gateway sends every request here and
// the app picks the operation from the method and path.
export function createApp(deps: Deps) {
  return async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const route = routes[`${event.httpMethod} ${event.path}`];
    if (!route) return json(404, { message: "Not found" });
    return route(deps);
  };
}
