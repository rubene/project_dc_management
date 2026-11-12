import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import type { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { appointSelfAsAdmin, listAdmins, removeAdmin } from "./admins.js";
import { changeCenter, getCenter, getCenterHistory } from "./centers.js";
import type { Clock } from "./clock.js";
import { getHealth } from "./health.js";
import { acceptInvitation, createInvitation } from "./invitations.js";
import { json } from "./http.js";
import { addCenter, createOrganization, listCenters } from "./organizations.js";
import { getMe, signUp } from "./people.js";

export type Deps = {
  clock: Clock;
  db: DynamoDBDocumentClient;
  tableName: string;
};

// The values of a path's `{name}` parts, such as `orgId`.
export type PathParams = Record<string, string | undefined>;

export type Route = (deps: Deps, event: APIGatewayProxyEvent, params: PathParams) => Promise<APIGatewayProxyResult>;

// Operations are named as in api/openapi.yaml.
const routes: Record<string, Route> = {
  "GET /health": getHealth,
  "GET /me": getMe,
  "PUT /me": signUp,
  "POST /organizations": createOrganization,
  "POST /organizations/{orgId}/centers": addCenter,
  "GET /organizations/{orgId}/centers": listCenters,
  "GET /centers/{centerId}": getCenter,
  "PATCH /centers/{centerId}": changeCenter,
  "GET /centers/{centerId}/history": getCenterHistory,
  "POST /centers/{centerId}/invitations": createInvitation,
  "POST /centers/{centerId}/invitations/accept": acceptInvitation,
  "GET /centers/{centerId}/admins": listAdmins,
  "PUT /centers/{centerId}/admins/{personId}": appointSelfAsAdmin,
  "DELETE /centers/{centerId}/admins/{personId}": removeAdmin,
};

const matchers = Object.entries(routes).map(([operation, route]) => {
  const [method, template] = operation.split(" ") as [string, string];
  const pattern = new RegExp(`^${template.replace(/\{(\w+)\}/g, "(?<$1>[^/]+)")}$`);
  return { operation, method, pattern, route };
});

// The whole API behind one Lambda. API Gateway sends every request here and
// the app picks the operation from the method and path.
export function createApp(deps: Deps) {
  return async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    for (const { operation, method, pattern, route } of matchers) {
      const match = method === event.httpMethod && pattern.exec(event.path);
      if (!match) continue;
      try {
        return await route(deps, event, { ...match.groups });
      } catch (error) {
        // Logs name the operation, so they give per-operation metrics (ADR 0009).
        console.error("Request failed", { operation, error });
        throw error;
      }
    }
    return json(404, { message: "Not found" });
  };
}
