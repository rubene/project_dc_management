import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import type { Deps, PathParams, Route } from "./app.js";
import { loginFrom, type Login } from "./auth.js";
import { mustHoldRole, rolesOf } from "./centerPeople.js";
import { json } from "./http.js";
import { mustExist } from "./idempotency.js";
import { consistentGet } from "./reads.js";
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
export function signedUp(handler: Handler<Person & { email: string; emailVerified: boolean }>): Route {
  return signedIn(async (deps, request, { personId, email, emailVerified }) => {
    if (!personId) return json(403, { message: "Sign up first, then refresh the login's tokens" });
    return handler(deps, request, { personId, email, emailVerified });
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

// What a caller was let in as at a Center.
export type CenterAccessLevel = "Owner" | "Admin";

export type CenterCaller = Person & {
  centerId: string;
  orgId: string;
  profile: Record<string, unknown>;
  access: CenterAccessLevel;
};

// An Owner of the Organization the Center in the path belongs to. The handler
// gets the Center's profile (C1), read consistently.
export function centerOwner(handler: Handler<CenterCaller>): Route {
  return atCenter(["Owner"], handler);
}

// An Owner of the Center's Organization, or an Admin of the Center itself.
// An Admin of one Center gets a 404 at every other Center.
export function centerManager(handler: Handler<CenterCaller>): Route {
  return atCenter(["Owner", "Admin"], handler);
}

function atCenter(allowed: CenterAccessLevel[], handler: Handler<CenterCaller>): Route {
  return signedUp(async (deps, request, { personId }) => {
    const { centerId } = request.params;
    if (!centerId) return centerNotFound();
    const [profile, roles] = await Promise.all([
      consistentGet(deps, keys.center(centerId).profile),
      allowed.includes("Admin") ? centerRoles(deps, { centerId, personId }) : Promise.resolve<string[]>([]),
    ]);
    if (!profile) return centerNotFound();
    // The Owner check uses the Organization the Center itself names.
    const { orgId } = profile;
    if (typeof orgId !== "string" || !orgId) return centerNotFound();
    const caller = { personId, centerId, orgId, profile };
    if (await isOwner(deps, { orgId, personId })) return handler(deps, request, { ...caller, access: "Owner" });
    if (roles.includes("Admin")) return handler(deps, request, { ...caller, access: "Admin" });
    return centerNotFound();
  });
}

// A transaction check that the caller still has the access they were let in
// with, so access removed while a request is in flight stops its write.
export function stillAllowed(tableName: string, { access, orgId, centerId, personId }: CenterCaller) {
  return access === "Owner"
    ? mustExist(tableName, keys.orgOwner({ orgId, personId }))
    : mustHoldRole(tableName, keys.center(centerId).person(personId), "Admin");
}

// A3: a person's Roles at a Center, read consistently.
async function centerRoles(deps: Deps, { centerId, personId }: { centerId: string; personId: string }) {
  return rolesOf(await consistentGet(deps, keys.center(centerId).person(personId)));
}

export function centerNotFound() {
  return json(404, { message: "Center not found" });
}

export function organizationNotFound() {
  return json(404, { message: "Organization not found" });
}

// A5: whether a person is an Owner of an Organization. Access checks always
// read the base table with a strongly consistent read, so removing access
// takes effect on the next request.
async function isOwner(deps: Deps, owner: { orgId: string; personId: string }): Promise<boolean> {
  return await consistentGet(deps, keys.orgOwner(owner)) !== undefined;
}
