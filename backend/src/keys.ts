import { mainTableKeys } from "./mainTable.js";

// The only place main-table keys are built (docs/data-model.md, ADR 0010).
// Partitions outside a Center are listed here one by one; a Center key can't
// be built without a Center ID.

const { partitionKey, sortKey } = mainTableKeys;

type Key = { [partitionKey]: string; [sortKey]: string };
type Prefix = { partition: string; sortPrefix: string };

function key(partition: string, sort: string): Key {
  return { [partitionKey]: partition, [sortKey]: sort };
}

export const keys = {
  // A1: the person a Cognito login belongs to.
  login: (sub: string) => key(`LOGIN#${sub}`, "LOGIN"),
  personProfile: (personId: string) => key(`PERSON#${personId}`, "PROFILE"),
  // A2: every Organization and Center a person belongs to.
  personAccess: (personId: string): Prefix => ({ partition: `PERSON#${personId}`, sortPrefix: "ACCESS#" }),
  personOrgAccess: ({ personId, orgId }: { personId: string; orgId: string }) =>
    key(`PERSON#${personId}`, `ACCESS#O#${orgId}`),

  organization: (orgId: string) => key(`ORG#${orgId}`, "ORG"),
  // A5: whether a person is an Owner of an Organization.
  orgOwner: ({ orgId, personId }: { orgId: string; personId: string }) => key(`ORG#${orgId}`, `OWNER#${personId}`),
  // C2: an Organization's Centers.
  orgCenter: ({ orgId, centerId }: { orgId: string; centerId: string }) => key(`ORG#${orgId}`, `CENTER#${centerId}`),
  orgCenters: (orgId: string): Prefix => ({ partition: `ORG#${orgId}`, sortPrefix: "CENTER#" }),

  // Every Center, for operations only. Creating a Center adds it here, and no
  // request handler reads it.
  allCentersEntry: (centerId: string) => key("CENTERS", `CENTER#${centerId}`),

  // Everything inside a Center starts from here, so it needs a Center ID.
  center: (centerId: string) => centerKeys(centerId),
};

function centerKeys(centerId: string) {
  if (!centerId) throw new Error("A Center key needs a Center ID");
  const partition = `C#${centerId}`;
  return {
    // C1: the Center's profile, a head with history.
    profile: key(partition, "CENTER"),
    profileHistory: (version: number) => key(partition, `H#CENTER#${String(version).padStart(6, "0")}`),
    // Every version of the profile, oldest first.
    profileVersions: { partition, sortPrefix: "H#CENTER#" } satisfies Prefix,
  };
}

// The parts of a Query that read one partition's items whose sort key starts
// with a prefix.
export function queryByPrefix({ partition, sortPrefix }: Prefix) {
  return {
    KeyConditionExpression: "#pk = :pk AND begins_with(#sk, :prefix)",
    ExpressionAttributeNames: { "#pk": partitionKey, "#sk": sortKey },
    ExpressionAttributeValues: { ":pk": partition, ":prefix": sortPrefix },
  };
}

// Conditions on whether an item with a given key is in the table.
export const itemIsNew = {
  ConditionExpression: "attribute_not_exists(#pk)",
  ExpressionAttributeNames: { "#pk": partitionKey },
};
export const itemExists = {
  ConditionExpression: "attribute_exists(#pk)",
  ExpressionAttributeNames: { "#pk": partitionKey },
};
