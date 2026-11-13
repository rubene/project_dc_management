import { createHash, randomBytes } from "node:crypto";
import { TransactionCanceledException } from "@aws-sdk/client-dynamodb";
import { TransactWriteCommand } from "@aws-sdk/lib-dynamodb";
import { centerNotFound, centerOwner, signedUp, stillAllowed } from "./access.js";
import { json, parseBody } from "./http.js";
import { createOnly, writeOnce } from "./idempotency.js";
import { centerAccess, grantRole, rolesOf, type CenterRole } from "./centerPeople.js";
import { keys } from "./keys.js";
import { mainTableKeys } from "./mainTable.js";
import { consistentGet } from "./reads.js";
import { recordedBy } from "./records.js";
import { cleanEmail, cleanName, isObject, unknownField, type Parsed } from "./validation.js";

// How long an invitation link works.
const invitationLifetimeMs = 7 * 24 * 60 * 60 * 1000;

// The Roles a person can be invited to. Staff and Guardians come later.
const invitableRoles: readonly CenterRole[] = ["Admin"];

type NewInvitation = { role: CenterRole; name: string; email: string };

// An Owner invites a person to a Center by email. The response holds the
// invitation's token, the only time it's ever shown, for the Owner to send as
// a link. Only a login with the same email can accept it.
//
// Sending the same request again makes another invitation with its own token.
// An unused one just expires, so there's nothing to deduplicate.
export const createInvitation = centerOwner(async ({ clock, db, tableName }, { event }, caller) => {
  const parsed = parseNewInvitation(parseBody(event));
  if ("problem" in parsed) return json(400, { message: parsed.problem });
  const { role, name, email } = parsed.value;
  const { personId, centerId, orgId } = caller;

  const now = clock.now();
  const token = randomBytes(32).toString("base64url");
  const expiresAt = new Date(now.getTime() + invitationLifetimeMs);
  const invitation = { centerId, role, name, email, expiresAt: expiresAt.toISOString() };

  const saved = await writeOnce(db, [
    createOnly(tableName, {
      ...keys.center(centerId).invitation(tokenHash(token)), type: "Invitation", orgId, ...invitation,
      ttl: Math.floor(expiresAt.getTime() / 1000), ...recordedBy(personId, now),
    }),
    stillAllowed(tableName, caller),
  ], () => false);
  if (saved.outcome === "refused") return centerNotFound();
  if (saved.outcome !== "written") throw new Error(`The invitation couldn't be saved: ${saved.outcome}`);
  return json(201, { ...invitation, token });
});

// The invited person accepts with the token from their link, and gets the
// invitation's Role at the Center. An invitation works once. Accepting it
// again returns the same result while the person still holds the Role, so the
// app can retry, but it never gives the Role back after an Owner removed it.
export const acceptInvitation = signedUp(async (deps, { event, params }, { personId, email, emailVerified }) => {
  const { clock, db, tableName } = deps;
  const centerId = params.centerId;
  const body = parseBody(event);
  if (!isObject(body) || unknownField(body, ["token"]) || typeof body.token !== "string" || !body.token) {
    return json(400, { message: "Accepting an invitation takes only its token" });
  }
  if (!centerId) return invitationNotFound();
  const centerKeys = keys.center(centerId);
  const invitationKey = centerKeys.invitation(tokenHash(body.token));
  const accessKey = keys.personCenterAccess({ personId, centerId });

  const now = clock.now();
  const read = (key: Record<string, string>) => consistentGet(deps, key);
  // A repeat of an accepted invitation by the same person.
  const repeated = async (role: string) => {
    const access = await read(accessKey);
    return access && rolesOf(access).includes(role) ? json(200, centerAccess(access)) : invitationNotFound();
  };

  const [invitation, profile, person] = await Promise.all([
    read(invitationKey), read(centerKeys.profile), read(keys.personProfile(personId)),
  ]);
  if (!invitation || !profile || !person) return invitationNotFound();
  if (typeof invitation.expiresAt !== "string" || invitation.expiresAt <= now.toISOString()) return invitationNotFound();
  if (!emailVerified || invitation.email !== email.toLowerCase()) {
    return json(403, { message: "This invitation is for a different email address. Sign in with that one, confirmed, to accept it." });
  }
  const role = invitation.role as CenterRole;
  if (invitation.acceptedBy !== undefined) {
    return invitation.acceptedBy === personId ? repeated(role) : invitationNotFound();
  }

  try {
    await db.send(new TransactWriteCommand({
      TransactItems: [
        {
          // Still unused and not yet expired.
          Update: {
            TableName: tableName,
            Key: invitationKey,
            UpdateExpression: "SET acceptedBy = :person, acceptedAt = :now",
            ConditionExpression: "attribute_exists(#pk) AND attribute_not_exists(acceptedBy) AND expiresAt > :now",
            ExpressionAttributeNames: { "#pk": mainTableKeys.partitionKey },
            ExpressionAttributeValues: { ":person": personId, ":now": now.toISOString() },
          },
        },
        ...grantRole(tableName, { center: profile, person }, role, recordedBy(personId, now)),
      ],
    }));
  } catch (error) {
    if (!(error instanceof TransactionCanceledException)) throw error;
    // A retry arriving at the same moment may have accepted it.
    const current = await read(invitationKey);
    return current?.acceptedBy === personId ? repeated(role) : invitationNotFound();
  }
  return repeated(role);
});

function tokenHash(token: string) {
  return createHash("sha256").update(token).digest("base64url");
}

// No such invitation, or it has expired or been used by someone else. The
// cases aren't told apart.
function invitationNotFound() {
  return json(404, { message: "This invitation doesn't exist, has expired or has already been used" });
}

function parseNewInvitation(body: unknown): Parsed<NewInvitation> {
  if (!isObject(body)) return { problem: "Send the invitation as a JSON object" };
  const unknown = unknownField(body, ["role", "name", "email"]);
  if (unknown) return { problem: `An invitation has no field "${unknown}"` };
  if (!invitableRoles.includes(body.role as CenterRole)) {
    return { problem: `An invitation's role must be ${invitableRoles.join(" or ")}` };
  }
  const name = cleanName(body.name);
  if (!name) return { problem: "An invitation needs the person's name, 1 to 200 characters" };
  const email = cleanEmail(body.email);
  if (!email) return { problem: "An invitation needs the person's email address" };
  return { value: { role: body.role as CenterRole, name, email } };
}
