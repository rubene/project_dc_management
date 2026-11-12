import { TransactionCanceledException } from "@aws-sdk/client-dynamodb";
import { GetCommand, QueryCommand, TransactWriteCommand } from "@aws-sdk/lib-dynamodb";
import { centerManager, centerNotFound, centerOwner, stillAllowed } from "./access.js";
import { grantRole, revokeRole, rolesOf } from "./centerPeople.js";
import { json } from "./http.js";
import { keys, queryByPrefix } from "./keys.js";
import { recordedBy } from "./records.js";

// An Owner of a single Center can also be its Admin, without inviting
// themselves. Anyone else becomes an Admin by accepting an invitation, so the
// Owner can't give a Role to a person who hasn't agreed to it.
export const appointSelfAsAdmin = centerOwner(async ({ clock, db, tableName }, { params }, caller) => {
  const { personId, profile } = caller;
  if (params.personId !== personId) {
    return json(400, { message: "An Owner can only appoint themselves directly. Invite anyone else." });
  }
  const { Item: person } = await db.send(new GetCommand({ TableName: tableName, Key: keys.personProfile(personId) }));
  if (!person) return json(403, { message: "This login's person doesn't exist" });

  try {
    await db.send(new TransactWriteCommand({
      TransactItems: [
        ...grantRole(tableName, { center: profile, person }, "Admin", recordedBy(personId, clock.now())),
        stillAllowed(tableName, caller),
      ],
    }));
  } catch (error) {
    // Only an Owner removed while the request was in flight gets here.
    if (error instanceof TransactionCanceledException) return centerNotFound();
    throw error;
  }
  return json(200, admin(person));
});

// A7: the Center's Admins.
export const listAdmins = centerManager(async ({ db, tableName }, _request, { centerId }) => {
  const items = [];
  let startKey: Record<string, unknown> | undefined;
  do {
    const page = await db.send(new QueryCommand({
      TableName: tableName,
      ...queryByPrefix(keys.center(centerId).people),
      ConsistentRead: true,
      ExclusiveStartKey: startKey,
    }));
    items.push(...(page.Items ?? []));
    startKey = page.LastEvaluatedKey;
  } while (startKey);
  return json(200, { admins: items.filter((item) => rolesOf(item).includes("Admin")).map(admin) });
});

function admin(item: Record<string, unknown>) {
  return { personId: item.personId, name: item.name, email: item.email };
}

// An Owner takes the Admin Role away from a person, themselves included. It
// takes effect on the person's next request, since access checks read the
// table consistently. Removing someone who isn't an Admin changes nothing.
export const removeAdmin = centerOwner(async ({ clock, db, tableName }, { params }, caller) => {
  const { personId: adminId } = params;
  if (!adminId) return json(404, { message: "Not found" });
  const now = clock.now();
  try {
    await db.send(new TransactWriteCommand({
      TransactItems: [
        ...revokeRole(tableName, { centerId: caller.centerId, personId: adminId }, "Admin", recordedBy(caller.personId, now)),
        stillAllowed(tableName, caller),
      ],
    }));
  } catch (error) {
    if (!(error instanceof TransactionCanceledException)) throw error;
    const reasons = error.CancellationReasons ?? [];
    // The Owner was removed while the request was in flight.
    if (reasons[2]?.Code === "ConditionalCheckFailed") return centerNotFound();
    // Otherwise the person wasn't an Admin.
    if (!reasons.some((reason) => reason.Code === "ConditionalCheckFailed")) throw error;
  }
  return { statusCode: 204, headers: {}, body: "" };
});
