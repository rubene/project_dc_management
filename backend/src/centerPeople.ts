import { keys } from "./keys.js";
import type { recordedBy } from "./records.js";

// A person's Roles at a Center are written twice, in one transaction
// (docs/data-model.md): the Center's copy, `C#<c>#PEOPLE / PERSON#<p>`, which
// access checks read, and the person's own, `PERSON#<p> / ACCESS#C#<c>`,
// which lists their Centers at login. Roles are a string set, so adding or
// removing one leaves the others alone.

export type CenterRole = "Admin";

type Item = Record<string, unknown>;
type Recorded = ReturnType<typeof recordedBy>;

// The two transaction updates that give a person a Role at a Center, creating
// their items there if needed. `center` and `person` are their profiles.
export function grantRole(tableName: string, { center, person }: { center: Item; person: Item }, role: CenterRole, recorded: Recorded) {
  const centerId = center.centerId as string;
  const personId = person.personId as string;
  return [
    addRole(tableName, keys.center(centerId).person(personId), role, {
      type: "CenterPerson", centerId, personId, name: person.name, email: person.email, ...recorded,
    }),
    addRole(tableName, keys.personCenterAccess({ personId, centerId }), role, {
      type: "CenterAccess", centerId, orgId: center.orgId, personId, centerName: center.name, ...recorded,
    }),
  ];
}

// The two transaction updates that take a Role away. Both fail if the person
// doesn't hold it, so nothing is created for a person who was never there.
export function revokeRole(tableName: string, { centerId, personId }: { centerId: string; personId: string }, role: CenterRole, recorded: Recorded) {
  return [keys.center(centerId).person(personId), keys.personCenterAccess({ personId, centerId })].map((key) => ({
    Update: {
      TableName: tableName,
      Key: key,
      UpdateExpression: "DELETE #roles :role SET recordedAt = :at, recordedBy = :by, recordedVia = :via",
      ConditionExpression: "contains(#roles, :held)",
      ExpressionAttributeNames: { "#roles": "roles" },
      ExpressionAttributeValues: {
        ":role": new Set([role]), ":held": role,
        ":at": recorded.recordedAt, ":by": recorded.recordedBy, ":via": recorded.recordedVia,
      },
    },
  }));
}

// A transaction check that a person's item at a Center still holds a Role,
// such as the Admin Role that allows a write.
export function mustHoldRole(tableName: string, key: Item, role: CenterRole) {
  return {
    ConditionCheck: {
      TableName: tableName,
      Key: key,
      ConditionExpression: "contains(#roles, :role)",
      ExpressionAttributeNames: { "#roles": "roles" },
      ExpressionAttributeValues: { ":role": role },
    },
  };
}

// The Roles on an item, sorted. Removing the last one removes the attribute.
export function rolesOf(item: Item | undefined): string[] {
  return item?.roles instanceof Set ? [...item.roles as Set<string>].sort() : [];
}

// A Center in a person's list of Centers, as GET /me shows it.
export function centerAccess(item: Item) {
  return { id: item.centerId, name: item.centerName, orgId: item.orgId, roles: rolesOf(item) };
}

// An update that adds a Role to a person's item and sets its other fields.
function addRole(tableName: string, key: Item, role: CenterRole, fields: Item) {
  const names = Object.keys(fields);
  return {
    Update: {
      TableName: tableName,
      Key: key,
      UpdateExpression: `ADD #roles :role SET ${names.map((_, i) => `#f${i} = :f${i}`).join(", ")}`,
      ExpressionAttributeNames: { "#roles": "roles", ...Object.fromEntries(names.map((name, i) => [`#f${i}`, name])) },
      ExpressionAttributeValues: {
        ":role": new Set([role]),
        ...Object.fromEntries(names.map((name, i) => [`:f${i}`, fields[name]])),
      },
    },
  };
}
