import { QueryCommand } from "@aws-sdk/lib-dynamodb";
import { orgOwner, organizationNotFound, signedUp } from "./access.js";
import { json, parseBody } from "./http.js";
import { createOnce, createOnly, mustExist, requestHash, type CreateOutcome } from "./idempotency.js";
import { isDeviceId } from "./ids.js";
import { keys, queryByPrefix } from "./keys.js";
import { recordedBy } from "./records.js";
import { cleanName, isObject, unknownField } from "./validation.js";

const currencies = ["USD", "CAD"] as const;
type Currency = (typeof currencies)[number];

type NewCenter = { id: string; name: string; currency: Currency; timezone: string };
type NewOrganization = { id: string; name: string; center: NewCenter };
type Center = NewCenter & { orgId: string; version: number };

// An Owner creates their Organization together with its first Center, so an
// Organization never exists without a Center.
export const createOrganization = signedUp(async ({ clock, db, tableName }, { event }, { personId }) => {
  const now = clock.now();
  const parsed = parseNewOrganization(parseBody(event), now);
  if ("problem" in parsed) return json(400, { message: parsed.problem });
  const request = parsed.value;

  const orgId = request.id;
  const center = centerFrom(request.center, orgId);
  const result = { id: orgId, name: request.name, centers: [center] };
  const created = { requestHash: requestHash(personId, request), result: JSON.stringify(result) };
  const recorded = recordedBy(personId, now);

  const saved = await createOnce(db, [
    // Keeps the request's hash and result, so a retry gets the result back
    // from the failed condition without a second read.
    createOnly(tableName, {
      ...keys.organization(orgId), type: "Organization", orgId, name: request.name,
      createdAt: recorded.recordedAt, ...recorded, ...created,
    }, { returnExisting: true }),
    createOnly(tableName, { ...keys.orgOwner({ orgId, personId }), type: "Owner", orgId, personId, ...recorded }),
    createOnly(tableName, {
      ...keys.personOrgAccess({ personId, orgId }), type: "OrganizationAccess",
      orgId, personId, orgName: request.name, roles: ["Owner"], ...recorded,
    }),
    ...newCenterWrites(tableName, center, { recorded, created }),
  ], (original) => original.requestHash === created.requestHash);

  return createdResponse(saved, result, "An Organization or Center with that ID already exists");
});

// An Owner adds another Center to their Organization.
export const addCenter = orgOwner(async ({ clock, db, tableName }, { event }, { personId, orgId }) => {
  const now = clock.now();
  const parsed = parseNewCenter(parseBody(event), now);
  if ("problem" in parsed) return json(400, { message: parsed.problem });

  const center = centerFrom(parsed.value, orgId);
  const created = { requestHash: requestHash(personId, { orgId, request: parsed.value }), result: JSON.stringify(center) };

  const saved = await createOnce(db, [
    ...newCenterWrites(tableName, center, { recorded: recordedBy(personId, now), created }),
    // The person must still be an Owner when the Center is saved, not only
    // when the request was checked.
    mustExist(tableName, keys.orgOwner({ orgId, personId })),
  ], (original) => original.requestHash === created.requestHash);

  return createdResponse(saved, center, "A Center with that ID already exists");
});

// C2: an Organization's Centers.
export const listCenters = orgOwner(async ({ db, tableName }, _request, { orgId }) => {
  const { Items = [] } = await db.send(new QueryCommand({ TableName: tableName, ...queryByPrefix(keys.orgCenters(orgId)) }));
  return json(200, { centers: Items.map((item) => ({ id: item.centerId, name: item.name })) });
});

// The response to a create: 201 with the result, the original result for a
// repeat of the same request, or 409 for a different request with the same ID.
function createdResponse(saved: CreateOutcome, result: unknown, conflictMessage: string) {
  switch (saved.outcome) {
    case "created": return json(201, result);
    case "repeated": return json(201, JSON.parse(saved.original.result as string));
    case "conflict": return json(409, { message: conflictMessage });
    // Only an Owner removed while the request was in flight gets here.
    case "refused": return organizationNotFound();
  }
}

function centerFrom(request: NewCenter, orgId: string): Center {
  return { ...request, orgId, version: 1 };
}

type CenterRecording = {
  recorded: ReturnType<typeof recordedBy>;
  // The create request's hash and result, kept on the profile's first history
  // item (docs/data-model.md, "Duplicate-safe retries").
  created: { requestHash: string; result: string };
};

// A new Center: the profile's first history item, its head, and its place in
// the Organization's and the operations-only lists of Centers. The history
// item comes first, so a repeated request finds its hash there.
function newCenterWrites(tableName: string, center: Center, { recorded, created }: CenterRecording) {
  const centerKeys = keys.center(center.id);
  const profile = { type: "Center", centerId: center.id, ...center, createdAt: recorded.recordedAt, ...recorded };
  const { orgId, id: centerId } = center;
  return [
    createOnly(tableName, {
      ...centerKeys.profileHistory(1), ...profile, type: "CenterHistory", reason: "Created", ...created,
    }, { returnExisting: true }),
    createOnly(tableName, { ...centerKeys.profile, ...profile }),
    createOnly(tableName, {
      ...keys.orgCenter({ orgId, centerId }), type: "OrganizationCenter", orgId, centerId, name: center.name, ...recorded,
    }),
    createOnly(tableName, { ...keys.allCentersEntry(centerId), type: "CenterListing", orgId, centerId, ...recorded }),
  ];
}

type Parsed<T> = { value: T } | { problem: string };

const idProblem = "IDs must be ULIDs created by the app within 7 days of the server's time";

function parseNewOrganization(body: unknown, now: Date): Parsed<NewOrganization> {
  if (!isObject(body)) return { problem: "Send the Organization as a JSON object" };
  const unknown = unknownField(body, ["id", "name", "center"]);
  if (unknown) return { problem: `An Organization has no field "${unknown}"` };
  if (!isDeviceId(body.id, now)) return { problem: idProblem };
  const name = cleanName(body.name);
  if (!name) return { problem: "An Organization needs a name of 1 to 200 characters" };
  const center = parseNewCenter(body.center, now);
  if ("problem" in center) return center;
  return { value: { id: body.id, name, center: center.value } };
}

function parseNewCenter(body: unknown, now: Date): Parsed<NewCenter> {
  if (!isObject(body)) return { problem: "Send the Center as a JSON object" };
  const unknown = unknownField(body, ["id", "name", "currency", "timezone"]);
  if (unknown) return { problem: `A Center has no field "${unknown}"` };
  if (!isDeviceId(body.id, now)) return { problem: idProblem };
  const name = cleanName(body.name);
  if (!name) return { problem: "A Center needs a name of 1 to 200 characters" };
  if (!isCurrency(body.currency)) return { problem: `A Center's currency must be ${currencies.join(" or ")}` };
  const timezone = ianaTimezone(body.timezone);
  if (!timezone) return { problem: "A Center's timezone must be an IANA timezone, such as America/Vancouver" };
  return { value: { id: body.id, name, currency: body.currency, timezone } };
}

function isCurrency(value: unknown): value is Currency {
  return currencies.includes(value as Currency);
}

// The IANA timezone's official spelling, such as America/Vancouver for
// "america/vancouver", or undefined if it isn't one. Intl knows every IANA
// name, aliases included. It also takes UTC offsets such as "+05:00", which
// aren't IANA names and don't follow daylight saving.
function ianaTimezone(timezone: unknown): string | undefined {
  if (typeof timezone !== "string" || !/^[A-Za-z]/.test(timezone)) return undefined;
  try {
    return new Intl.DateTimeFormat("en-US", { timeZone: timezone }).resolvedOptions().timeZone;
  } catch {
    return undefined;
  }
}
