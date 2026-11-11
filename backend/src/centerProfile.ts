// A Center's profile as the API returns it (the CenterProfile schema), built
// in one place so every operation returns the same shape.

export const currencies = ["USD", "CAD"] as const;
export type Currency = (typeof currencies)[number];

export type CenterProfile = {
  id: string;
  orgId: string;
  name: string;
  currency: Currency;
  timezone: string;
  version: number;
};

// The first version of a new Center's profile.
export function newCenterProfile(
  request: { id: string; name: string; currency: Currency; timezone: string }, orgId: string,
): CenterProfile {
  return { id: request.id, orgId, name: request.name, currency: request.currency, timezone: request.timezone, version: 1 };
}

// The API's view of a stored profile head or history item.
export function centerProfile(item: Record<string, unknown>): CenterProfile {
  return {
    id: item.centerId as string,
    orgId: item.orgId as string,
    name: item.name as string,
    currency: item.currency as Currency,
    timezone: item.timezone as string,
    version: item.version as number,
  };
}
