import { GetCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";
import { ulid } from "ulid";
import { signedIn, signedUp } from "./access.js";
import { centerAccess, rolesOf } from "./centerPeople.js";
import { json, parseBody } from "./http.js";
import { writeOnce, createOnly } from "./idempotency.js";
import { keys, queryByPrefix } from "./keys.js";
import { recordedBy } from "./records.js";
import { cleanName, isObject, unknownField } from "./validation.js";

// Signs up the person behind a new Cognito login. Their person ID is separate
// from the login, because people without a login need IDs too. A login is
// only ever one person, so signing up again returns the same person.
export const signUp = signedIn(async ({ clock, db, tableName }, { event }, login) => {
  const body = parseBody(event);
  if (!isObject(body) || unknownField(body, ["name"])) return json(400, { message: "Signing up takes only a name" });
  const name = cleanName(body.name);
  if (!name) return json(400, { message: "Signing up needs a name of 1 to 200 characters" });

  const now = clock.now();
  const personId = ulid(now.getTime());
  const person = { personId, name, email: login.email };
  const recorded = recordedBy(personId, now);

  const saved = await writeOnce(db, [
    // Holds the sign-up's result, so a retry gets it back from the failed
    // condition without a second read.
    createOnly(tableName, { ...keys.login(login.sub), type: "Login", ...person, ...recorded }, { returnExisting: true }),
    createOnly(tableName, { ...keys.personProfile(personId), type: "PersonProfile", ...person, ...recorded }),
  ], () => true);

  if (saved.outcome === "repeated") {
    const { original } = saved;
    return json(201, { personId: original.personId, name: original.name, email: original.email });
  }
  if (saved.outcome !== "written") throw new Error(`Sign-up couldn't be saved: ${saved.outcome}`);
  return json(201, person);
});

export const getMe = signedUp(async ({ db, tableName }, _request, { personId }) => {
  const [{ Item: profile }, { Items: access = [] }] = await Promise.all([
    db.send(new GetCommand({ TableName: tableName, Key: keys.personProfile(personId) })),
    db.send(new QueryCommand({ TableName: tableName, ...queryByPrefix(keys.personAccess(personId)) })),
  ]);
  // Only a token issued for another table, such as another stage's, gets here.
  if (!profile) return json(403, { message: "This login's person doesn't exist" });

  return json(200, {
    personId: profile.personId,
    name: profile.name,
    email: profile.email,
    organizations: access
      .filter((item) => item.type === "OrganizationAccess")
      .map((item) => ({ id: item.orgId, name: item.orgName, roles: item.roles })),
    // A Center whose last Role was removed keeps its item, without Roles.
    centers: access
      .filter((item) => item.type === "CenterAccess" && rolesOf(item).length > 0)
      .map(centerAccess),
  });
});
