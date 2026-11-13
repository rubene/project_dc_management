import { TransactionCanceledException } from "@aws-sdk/client-dynamodb";
import { GetCommand, TransactWriteCommand } from "@aws-sdk/lib-dynamodb";
import { centerManager, centerNotFound, centerOwner, stillAllowed } from "./access.js";
import { grantRole, revokeRole, rolesOf } from "./centerPeople.js";
import { json, noContent } from "./http.js";
import { keyOf, keys } from "./keys.js";
import { consistentGet, queryAll } from "./reads.js";
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
export const listAdmins = centerManager(async (deps, _request, { centerId }) => {
  const items = await queryAll(deps, keys.center(centerId).people);
  return json(200, { admins: items.filter((item) => rolesOf(item).includes("Admin")).map(admin) });
});

function admin(item: Record<string, unknown>) {
  return { personId: item.personId, name: item.name, email: item.email };
}

// An Owner takes the Admin Role away from a person, themselves included, and
// cancels the invitations to the Center they haven't accepted yet, so they
// can't come back without a new one. It takes effect on the person's next
// request, since access checks read the table consistently. Removing someone
// who isn't an Admin changes nothing else.
export const removeAdmin = centerOwner(async (deps, { params }, caller) => {
  const { clock, db, tableName } = deps;
  const { centerId } = caller;
  const personId = params.personId!;
  const centerKeys = keys.center(centerId);
  const recorded = recordedBy(caller.personId, clock.now());

  // The person may accept an invitation between these reads and the write.
  // Then the write's conditions fail, and reading again finds the new Role.
  for (let attempt = 1; ; attempt++) {
    const [person, profile, invitations] = await Promise.all([
      consistentGet(deps, centerKeys.person(personId)),
      consistentGet(deps, keys.personProfile(personId)),
      queryAll(deps, centerKeys.invitations),
    ]);
    const email = typeof profile?.email === "string" ? profile.email.toLowerCase() : undefined;
    const pending = invitations.filter((invitation) => invitation.email === email && invitation.acceptedBy === undefined);
    const writes = [
      ...(rolesOf(person).includes("Admin") ? revokeRole(tableName, { centerId, personId }, "Admin", recorded) : []),
      ...pending.map((invitation) => ({
        Delete: {
          TableName: tableName,
          Key: keyOf(invitation),
          ConditionExpression: "attribute_not_exists(acceptedBy)",
        },
      })),
    ];
    if (writes.length === 0) return noContent();

    const allowed = stillAllowed(tableName, caller);
    try {
      await db.send(new TransactWriteCommand({ TransactItems: [...writes, allowed] }));
      return noContent();
    } catch (error) {
      if (!(error instanceof TransactionCanceledException)) throw error;
      const reasons = error.CancellationReasons ?? [];
      // The Owner was removed while the request was in flight.
      if (reasons[writes.length]?.Code === "ConditionalCheckFailed") return centerNotFound();
      if (attempt === 3) throw error;
    }
  }
});
