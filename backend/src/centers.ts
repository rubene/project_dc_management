import { QueryCommand } from "@aws-sdk/lib-dynamodb";
import { centerManager, centerNotFound, stillAllowed } from "./access.js";
import { centerProfile } from "./centerProfile.js";
import { json, parseBody } from "./http.js";
import { writeOnce, createOnly, replaceIfVersion, requestHash } from "./idempotency.js";
import { keys, queryByPrefix } from "./keys.js";
import { recordedBy } from "./records.js";
import { deviceIdProblem, isDeviceId } from "./ids.js";
import { ianaTimezone, isObject, unknownField, type Parsed } from "./validation.js";

// C1: a Center's profile.
export const getCenter = centerManager(async (_deps, _request, { profile }) => json(200, centerProfile(profile)));

// Changes a Center's timezone. The profile is a head with history: the new
// version is written as a history item and the head is replaced, in one
// transaction that only succeeds if the head is still at the expected version.
// Records already saved keep the dates they were saved with.
export const changeCenter = centerManager(async ({ clock, db, tableName }, { event }, caller) => {
  const { personId, centerId, profile } = caller;
  const now = clock.now();
  const parsed = parseCenterChange(parseBody(event), now);
  if ("problem" in parsed) return json(400, { message: parsed.problem });
  const { changeId, expectedVersion, timezone, reason } = parsed.value;
  // A version the profile hasn't reached can't be current or a retry, so it
  // needs no transaction. An older one may be a retry, which the transaction
  // finds by its history item.
  if (expectedVersion > (profile.version as number)) return staleChange();

  const version = expectedVersion + 1;
  const changed = { ...profile, timezone, version, ...recordedBy(personId, now) };
  const centerKeys = keys.center(centerId);
  const hash = requestHash(personId, { centerId, change: parsed.value });

  const saved = await writeOnce(db, [
    // The new version's history item keeps the request's hash, so a retry of
    // this change finds it there, even after later changes.
    createOnly(tableName, {
      ...changed, ...centerKeys.profileHistory(version), type: "CenterHistory",
      changeId, ...(reason !== undefined && { reason }), requestHash: hash,
    }, { returnExisting: true }),
    replaceIfVersion(tableName, { ...changed, ...centerKeys.profile }, expectedVersion),
    // The person must still have their access when the change is saved.
    stillAllowed(tableName, caller),
  ], (original) => original.requestHash === hash);
  if (saved.outcome === "repeated") return json(200, centerProfile(saved.original));
  if (saved.outcome === "refused") return centerNotFound();
  if (saved.outcome === "conflict") return staleChange();
  return json(200, centerProfile(changed));
});

function staleChange() {
  return json(409, { message: "The Center has changed since this version. Read it again and redo the change." });
}

// Every version of a Center's profile, oldest first, with who saved it, when
// and why.
export const getCenterHistory = centerManager(async ({ db, tableName }, _request, { centerId }) => {
  const items = [];
  // A Query returns at most 1 MB at a time, so read every page.
  let startKey: Record<string, unknown> | undefined;
  do {
    const page = await db.send(new QueryCommand({
      TableName: tableName,
      ...queryByPrefix(keys.center(centerId).profileVersions),
      ConsistentRead: true,
      ExclusiveStartKey: startKey,
    }));
    items.push(...(page.Items ?? []));
    startKey = page.LastEvaluatedKey;
  } while (startKey);
  return json(200, {
    versions: items.map((item) => ({
      version: item.version,
      name: item.name,
      currency: item.currency,
      timezone: item.timezone,
      recordedAt: item.recordedAt,
      recordedBy: item.recordedBy,
      ...(item.reason !== undefined && { reason: item.reason }),
    })),
  });
});

type CenterChange = { changeId: string; expectedVersion: number; timezone: string; reason?: string };

function parseCenterChange(body: unknown, now: Date): Parsed<CenterChange> {
  if (!isObject(body)) return { problem: "Send the change as a JSON object" };
  const unknown = unknownField(body, ["changeId", "expectedVersion", "timezone", "reason"]);
  if (unknown) return { problem: `A change to a Center has no field "${unknown}"` };
  if (!isDeviceId(body.changeId, now)) return { problem: deviceIdProblem };
  const { expectedVersion, reason } = body;
  if (!Number.isInteger(expectedVersion) || (expectedVersion as number) < 1) {
    return { problem: "A change needs the profile's version it was made against, a whole number from 1" };
  }
  const timezone = ianaTimezone(body.timezone);
  if (!timezone) return { problem: "A Center's timezone must be an IANA timezone, such as America/Vancouver" };
  if (reason !== undefined && (typeof reason !== "string" || reason.length > 500)) {
    return { problem: "A change's reason must be text of up to 500 characters" };
  }
  return { value: { changeId: body.changeId, expectedVersion: expectedVersion as number, timezone, reason } };
}
