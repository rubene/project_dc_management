import { describe, expect, test } from "vitest";
import { testApi } from "../support/api.js";
import { fixedClock } from "../support/fakeClock.js";
import { deviceId } from "../support/ids.js";
import { signedUp } from "../support/logins.js";
import { ownerWithOrganization as ownerWithOrganizationAt } from "../support/organizations.js";

const clock = fixedClock("2026-03-14T15:09:26.000Z");
const api = testApi({ clock });
const ownerWithOrganization = () => ownerWithOrganizationAt(api, clock);

function newCenter(center: Record<string, unknown> = {}) {
  return { id: deviceId(clock), name: "Little Oaks Uptown", currency: "USD", timezone: "America/Los_Angeles", ...center };
}

describe("POST /organizations/{orgId}/centers", () => {
  test("an Owner adds another Center to their Organization", async () => {
    const { owner, orgId, firstCenterId } = await ownerWithOrganization();
    const center = newCenter();

    const created = await api.as(owner).post(`/organizations/${orgId}/centers`, center);

    expect(created.status).toBe(201);
    expect(created.body).toEqual({ ...center, orgId, version: 1 });
    const list = await api.as(owner).get(`/organizations/${orgId}/centers`);
    expect(list.status).toBe(200);
    expect((list.body as { centers: { id: string }[] }).centers.map((c) => c.id).sort())
      .toEqual([firstCenterId, center.id].sort());
  });

  // The app retries a create if it loses the response.
  test("sending the same new Center again returns the original result", async () => {
    const { owner, orgId } = await ownerWithOrganization();
    const center = newCenter();
    const first = await api.as(owner).post(`/organizations/${orgId}/centers`, center);

    const retry = await api.as(owner).post(`/organizations/${orgId}/centers`, center);

    expect(retry.status).toBe(201);
    expect(retry.body).toEqual(first.body);
  });

  test("reusing a Center's ID for a different Center is a conflict", async () => {
    const { owner, orgId, firstCenterId } = await ownerWithOrganization();

    const reused = await api.as(owner).post(`/organizations/${orgId}/centers`, newCenter({ id: firstCenterId }));

    expect(reused.status).toBe(409);
  });

  // 404 rather than 403, so nobody learns which Organizations exist.
  test("someone who isn't the Organization's Owner can't add a Center to it", async () => {
    const { orgId } = await ownerWithOrganization();
    const stranger = await signedUp(api, "Sam Stranger");

    const response = await api.as(stranger).post(`/organizations/${orgId}/centers`, newCenter());

    expect(response.status).toBe(404);
  });
});

describe("GET /organizations/{orgId}/centers", () => {
  test("someone who isn't the Organization's Owner can't list its Centers", async () => {
    const { orgId } = await ownerWithOrganization();
    const stranger = await signedUp(api, "Sam Stranger");

    const response = await api.as(stranger).get(`/organizations/${orgId}/centers`);

    expect(response.status).toBe(404);
  });
});
