import { describe, expect, test } from "vitest";
import { testApi } from "../support/api.js";
import { fixedClock } from "../support/fakeClock.js";
import { deviceId } from "../support/ids.js";
import { signedUp } from "../support/logins.js";
import { ownerWithOrganization } from "../support/organizations.js";

const clock = fixedClock("2026-03-14T15:09:26.000Z");
const api = testApi({ clock });

describe("GET /centers/{centerId}", () => {
  test("an Owner reads one of their Centers", async () => {
    const { owner, orgId, firstCenterId } = await ownerWithOrganization(api, clock);

    const response = await api.as(owner).get(`/centers/${firstCenterId}`);

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      id: firstCenterId,
      orgId,
      name: "Little Oaks Downtown",
      currency: "CAD",
      timezone: "America/Vancouver",
      version: 1,
    });
  });

  // 404 rather than 403, so nobody learns which Centers exist.
  test("someone who isn't an Owner of the Center's Organization can't read it", async () => {
    const { firstCenterId } = await ownerWithOrganization(api, clock);
    const stranger = await signedUp(api, "Sam Stranger");

    const response = await api.as(stranger).get(`/centers/${firstCenterId}`);

    expect(response.status).toBe(404);
  });
});

describe("PATCH /centers/{centerId}", () => {
  test("an Owner changes a Center's timezone", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization(api, clock);

    const changed = await api.as(owner).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(clock),
      expectedVersion: 1,
      timezone: "America/Toronto",
      reason: "We moved",
    });

    expect(changed.status).toBe(200);
    expect(changed.body).toMatchObject({ timezone: "America/Toronto", version: 2 });
    const center = await api.as(owner).get(`/centers/${firstCenterId}`);
    expect(center.body).toMatchObject({ timezone: "America/Toronto", version: 2 });
  });

  // Two people changing the profile at once mustn't both win.
  test("a change made against an old version is a conflict", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization(api, clock);
    await api.as(owner).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(clock), expectedVersion: 1, timezone: "America/Toronto",
    });

    const stale = await api.as(owner).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(clock), expectedVersion: 1, timezone: "America/Edmonton",
    });

    expect(stale.status).toBe(409);
    const center = await api.as(owner).get(`/centers/${firstCenterId}`);
    expect(center.body).toMatchObject({ timezone: "America/Toronto", version: 2 });
  });

  test("a change made against a version the Center hasn't reached is a conflict", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization(api, clock);

    const response = await api.as(owner).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(clock), expectedVersion: 5, timezone: "America/Toronto",
    });

    expect(response.status).toBe(409);
  });

  // The app retries a change if it loses the response, perhaps after someone
  // else has changed the Center again.
  test("sending the same change again returns the original result", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization(api, clock);
    const change = { changeId: deviceId(clock), expectedVersion: 1, timezone: "America/Toronto" };
    const first = await api.as(owner).patch(`/centers/${firstCenterId}`, change);
    await api.as(owner).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(clock), expectedVersion: 2, timezone: "America/Winnipeg",
    });

    const retry = await api.as(owner).patch(`/centers/${firstCenterId}`, change);

    expect(retry.status).toBe(200);
    expect(retry.body).toEqual(first.body);
    const center = await api.as(owner).get(`/centers/${firstCenterId}`);
    expect(center.body).toMatchObject({ timezone: "America/Winnipeg", version: 3 });
  });

  test("someone who isn't an Owner of the Center's Organization can't change it", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization(api, clock);
    const stranger = await signedUp(api, "Sam Stranger");

    const response = await api.as(stranger).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(clock), expectedVersion: 1, timezone: "America/Toronto",
    });

    expect(response.status).toBe(404);
    const center = await api.as(owner).get(`/centers/${firstCenterId}`);
    expect(center.body).toMatchObject({ timezone: "America/Vancouver", version: 1 });
  });

  test.each([
    ["a timezone that isn't IANA", { timezone: "Eastern Time" }],
    ["a change ID that isn't a ULID", { changeId: "change-1" }],
    ["no expected version", { expectedVersion: undefined }],
    ["an expected version that isn't a whole number", { expectedVersion: 1.5 }],
    ["a reason that isn't text", { reason: 42 }],
    ["a field the API doesn't know", { currency: "USD" }],
  ])("a change with %s is refused", async (_, fields) => {
    const { owner, firstCenterId } = await ownerWithOrganization(api, clock);

    const response = await api.as(owner).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(clock), expectedVersion: 1, timezone: "America/Toronto", ...fields,
    });

    expect(response.status).toBe(400);
  });
});

describe("GET /centers/{centerId}/history", () => {
  test("the history keeps every version, with who changed it, when and why", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization(api, clock);
    const later = fixedClock("2026-03-20T09:00:00.000Z");
    await testApi({ clock: later }).as(owner).patch(`/centers/${firstCenterId}`, {
      changeId: deviceId(later), expectedVersion: 1, timezone: "America/Toronto", reason: "We moved",
    });

    const history = await api.as(owner).get(`/centers/${firstCenterId}/history`);

    expect(history.status).toBe(200);
    expect(history.body).toEqual({
      versions: [
        {
          version: 1, timezone: "America/Vancouver", name: "Little Oaks Downtown", currency: "CAD",
          recordedAt: "2026-03-14T15:09:26.000Z", recordedBy: owner.personId, reason: "Created",
        },
        {
          version: 2, timezone: "America/Toronto", name: "Little Oaks Downtown", currency: "CAD",
          recordedAt: "2026-03-20T09:00:00.000Z", recordedBy: owner.personId, reason: "We moved",
        },
      ],
    });
  });
});
