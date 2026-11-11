import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { GetCommand } from "@aws-sdk/lib-dynamodb";
import type { Deps, PathParams, Route } from "./app.js";
import { loginFrom, type Login } from "./auth.js";
import { json } from "./http.js";
import { keys } from "./keys.js";

// Who may call an operation. Each wrapper turns a handler that needs a
// certain caller into a route that refuses everyone else.

type Request = { event: APIGatewayProxyEvent; params: PathParams };
type Handler<Caller> = (deps: Deps, request: Request, caller: Caller) => Promise<APIGatewayProxyResult>;

// Anyone with a login, signed up or not.
export function signedIn(handler: Handler<Login>): Route {
  return async (deps, event, params) => {
    const login = loginFrom(event);
    if (!login) return json(401, { message: "Sign in first" });
    return handler(deps, { event, params }, login);
  };
}

export type Person = { personId: string };

// A login that has signed up. A token without a person ID was issued before
// sign-up, so the app signs up and refreshes the token.
export function signedUp(handler: Handler<Person>): Route {
  return signedIn(async (deps, request, { personId }) => {
    if (!personId) return json(403, { message: "Sign up first, then refresh the login's tokens" });
    return handler(deps, request, { personId });
  });
}

export type Owner = Person & { orgId: string };

// An Owner of the Organization in the path. Anyone else gets a 404, so nobody
// learns which Organizations exist.
export function orgOwner(handler: Handler<Owner>): Route {
  return signedUp(async (deps, request, { personId }) => {
    const { orgId } = request.params;
    if (!orgId || !await isOwner(deps, { orgId, personId })) return organizationNotFound();
    return handler(deps, request, { personId, orgId });
  });
}

export function organizationNotFound() {
  return json(404, { message: "Organization not found" });
}

// A5: whether a person is an Owner of an Organization. Access checks always
// read the base table with a strongly consistent read, so removing access
// takes effect on the next request.
async function isOwner({ db, tableName }: Deps, owner: { orgId: string; personId: string }): Promise<boolean> {
  const { Item } = await db.send(new GetCommand({
    TableName: tableName,
    Key: keys.orgOwner(owner),
    ConsistentRead: true,
  }));
  return Item !== undefined;
}
