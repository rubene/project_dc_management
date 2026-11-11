import { describe, expect, test } from "vitest";
import { testApi } from "../support/api.js";
import { fixedClock } from "../support/fakeClock.js";
import { deviceId } from "../support/ids.js";
import { newLogin, signedUp } from "../support/logins.js";

const clock = fixedClock("2026-03-14T15:09:26.000Z");
const api = testApi({ clock });

function newOrganization(center: Record<string, unknown> = {}) {
  return {
    id: deviceId(clock),
    name: "Little Oaks",
    center: {
      id: deviceId(clock),
      name: "Little Oaks Downtown",
      currency: "CAD",
      timezone: "America/Vancouver",
      ...center,
    },
  };
}

describe("POST /organizations", () => {
  test("an Owner creates their Organization with its first Center", async () => {
    const owner = await signedUp(api);
    const organization = newOrganization();

    const created = await api.as(owner).post("/organizations", organization);

    expect(created.status).toBe(201);
    expect(created.body).toEqual({
      id: organization.id,
      name: "Little Oaks",
      centers: [{
        id: organization.center.id,
        orgId: organization.id,
        name: "Little Oaks Downtown",
        currency: "CAD",
        timezone: "America/Vancouver",
        version: 1,
      }],
    });
    const me = await api.as(owner).get("/me");
    expect(me.body).toMatchObject({
      organizations: [{ id: organization.id, name: "Little Oaks", roles: ["Owner"] }],
    });
  });

  test("a Center's currency must be USD or CAD", async () => {
    const owner = await signedUp(api);

    const response = await api.as(owner).post("/organizations", newOrganization({ currency: "EUR" }));

    expect(response.status).toBe(400);
  });

  test("a Center's timezone must be an IANA timezone", async () => {
    const owner = await signedUp(api);

    const response = await api.as(owner).post("/organizations", newOrganization({ timezone: "Pacific Time" }));

    expect(response.status).toBe(400);
  });

  test("a Center's timezone is saved under its official name", async () => {
    const owner = await signedUp(api);

    const created = await api.as(owner).post("/organizations", newOrganization({ timezone: "america/vancouver" }));

    expect(created.body).toMatchObject({ centers: [{ timezone: "America/Vancouver" }] });
  });

  test("IDs must be ULIDs created by the app", async () => {
    const owner = await signedUp(api);

    const response = await api.as(owner).post("/organizations", { ...newOrganization(), id: "org-1" });

    expect(response.status).toBe(400);
  });

  // A device with a wrong clock mustn't put a record outside retention.
  test("an ID made more than 7 days from the server's time is refused", async () => {
    const owner = await signedUp(api);
    const eightDaysAgo = fixedClock("2026-03-06T15:09:26.000Z");

    const response = await api.as(owner).post("/organizations", { ...newOrganization(), id: deviceId(eightDaysAgo) });

    expect(response.status).toBe(400);
  });

  // The app retries a create if it loses the response.
  test("sending the same create again returns the original result", async () => {
    const owner = await signedUp(api);
    const organization = newOrganization();
    const first = await api.as(owner).post("/organizations", organization);

    const retry = await api.as(owner).post("/organizations", organization);

    expect(retry.status).toBe(201);
    expect(retry.body).toEqual(first.body);
  });

  // A retry can reach the API while the first request is still being saved.
  test("the same create sent twice at once gives both the same result", async () => {
    const owner = await signedUp(api);
    const organization = newOrganization();

    const [first, second] = await Promise.all([
      api.as(owner).post("/organizations", organization),
      api.as(owner).post("/organizations", organization),
    ]);

    expect([first.status, second.status]).toEqual([201, 201]);
    expect(second.body).toEqual(first.body);
  });

  test("reusing an ID for a different request is a conflict", async () => {
    const owner = await signedUp(api);
    const organization = newOrganization();
    await api.as(owner).post("/organizations", organization);

    const reused = await api.as(owner).post("/organizations", { ...organization, name: "Big Oaks" });

    expect(reused.status).toBe(409);
  });

  // A login without a person ID in its token hasn't signed up, or its token
  // was issued before it did. The app signs up and refreshes the token.
  test("a login that hasn't signed up is told to sign up first", async () => {
    const response = await api.as(newLogin()).post("/organizations", newOrganization());

    expect(response.status).toBe(403);
  });

  test.each([
    ["without a name", { ...newOrganization(), name: "" }],
    ["without its first Center", { id: deviceId(clock), name: "Little Oaks" }],
    ["with a Center without a name", newOrganization({ name: undefined })],
    ["with a field the API doesn't know", { ...newOrganization(), plan: "gold" }],
    ["with a Center field the API doesn't know", newOrganization({ capacity: 80 })],
  ])("an Organization %s is refused", async (_, organization) => {
    const owner = await signedUp(api);

    const response = await api.as(owner).post("/organizations", organization);

    expect(response.status).toBe(400);
  });
});
