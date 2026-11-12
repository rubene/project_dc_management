import { describe, expect, test } from "vitest";
import { testApi } from "../support/api.js";
import { fixedClock } from "../support/fakeClock.js";
import { deviceId } from "../support/ids.js";
import { signedUp, type Login } from "../support/logins.js";
import { ownerWithOrganization as ownerWithOrganizationAt } from "../support/organizations.js";

const clock = fixedClock("2026-03-14T15:09:26.000Z");
const api = testApi({ clock });
const ownerWithOrganization = () => ownerWithOrganizationAt(api, clock);

// The Owner invites the person by their login's email, and the person accepts
// with the invitation's token.
function invite(owner: Login, centerId: string, person: Login, name = "Ari Admin") {
  return api.as(owner).post(`/centers/${centerId}/invitations`, { role: "Admin", name, email: person.email });
}

async function appointedAdmin(owner: Login, centerId: string, name = "Ari Admin") {
  const admin = await signedUp(api, name);
  const invitation = await invite(owner, centerId, admin, name);
  const { token } = invitation.body as { token: string };
  await api.as(admin).post(`/centers/${centerId}/invitations/accept`, { token });
  return admin;
}

describe("inviting an Admin", () => {
  test("an invited Admin accepts and can then manage the Center", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await signedUp(api, "Ari Admin");

    const invitation = await invite(owner, firstCenterId, admin);
    expect(invitation.status).toBe(201);
    const { token } = invitation.body as { token: string };

    const accepted = await api.as(admin).post(`/centers/${firstCenterId}/invitations/accept`, { token });

    expect(accepted.status).toBe(200);
    expect(accepted.body).toMatchObject({ id: firstCenterId, name: "Little Oaks Downtown", roles: ["Admin"] });
    const center = await api.as(admin).get(`/centers/${firstCenterId}`);
    expect(center.status).toBe(200);
    expect(center.body).toMatchObject({ id: firstCenterId, name: "Little Oaks Downtown" });
  });
});

describe("accepting an invitation", () => {
  async function invitationFor(person: Login) {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const { token } = (await invite(owner, firstCenterId, person)).body as { token: string };
    return { centerId: firstCenterId, token };
  }

  test("only a login with the invited email can accept", async () => {
    const invited = await signedUp(api, "Ari Admin");
    const { centerId, token } = await invitationFor(invited);
    const someoneElse = await signedUp(api, "Sam Stranger");

    const response = await api.as(someoneElse).post(`/centers/${centerId}/invitations/accept`, { token });

    expect(response.status).toBe(403);
    expect((await api.as(someoneElse).get(`/centers/${centerId}`)).status).toBe(404);
  });

  test("the invited email matches whatever its case", async () => {
    const invited = await signedUp(api, "Ari Admin");
    const { owner, firstCenterId } = await ownerWithOrganization();
    const { token } = (await api.as(owner).post(`/centers/${firstCenterId}/invitations`, {
      role: "Admin", name: "Ari Admin", email: ` ${invited.email.toUpperCase()} `,
    })).body as { token: string };

    const response = await api.as(invited).post(`/centers/${firstCenterId}/invitations/accept`, { token });

    expect(response.status).toBe(200);
  });

  // Cognito lets a person change their email, which leaves it unverified
  // until they confirm it.
  test("a login whose email isn't verified can't accept", async () => {
    const invited = await signedUp(api, "Ari Admin");
    const { centerId, token } = await invitationFor(invited);

    const response = await api.as({ ...invited, emailVerified: false })
      .post(`/centers/${centerId}/invitations/accept`, { token });

    expect(response.status).toBe(403);
    expect((await api.as(invited).get(`/centers/${centerId}`)).status).toBe(404);
  });

  // The app retries if it loses the response.
  test("accepting the same invitation again returns the same result", async () => {
    const invited = await signedUp(api, "Ari Admin");
    const { centerId, token } = await invitationFor(invited);
    const first = await api.as(invited).post(`/centers/${centerId}/invitations/accept`, { token });

    const again = await api.as(invited).post(`/centers/${centerId}/invitations/accept`, { token });

    expect(again.status).toBe(200);
    expect(again.body).toEqual(first.body);
  });

  test("an invitation stops working after 7 days", async () => {
    const invited = await signedUp(api, "Ari Admin");
    const { centerId, token } = await invitationFor(invited);
    const eightDaysLater = testApi({ clock: fixedClock("2026-03-22T15:09:26.000Z") });

    const response = await eightDaysLater.as(invited).post(`/centers/${centerId}/invitations/accept`, { token });

    expect(response.status).toBe(404);
  });

  test("a made-up token, or one for another Center, doesn't work", async () => {
    const invited = await signedUp(api, "Ari Admin");
    const { token } = await invitationFor(invited);
    const other = await ownerWithOrganization();

    const madeUp = await api.as(invited).post(`/centers/${other.firstCenterId}/invitations/accept`, { token: "made-up" });
    const elsewhere = await api.as(invited).post(`/centers/${other.firstCenterId}/invitations/accept`, { token });

    expect(madeUp.status).toBe(404);
    expect(elsewhere.status).toBe(404);
  });

  test("an invitation needs a valid email and a Role that can be invited", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const path = `/centers/${firstCenterId}/invitations`;

    expect((await api.as(owner).post(path, { role: "Admin", name: "Ari", email: "not-an-email" })).status).toBe(400);
    expect((await api.as(owner).post(path, { role: "Owner", name: "Ari", email: "ari@example.test" })).status).toBe(400);
  });
});

describe("an Admin's access", () => {
  function timezoneChange(version = 1) {
    return { changeId: deviceId(clock), expectedVersion: version, timezone: "America/Toronto" };
  }

  test("an Admin changes their own Center and sees its history", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);

    const changed = await api.as(admin).patch(`/centers/${firstCenterId}`, timezoneChange());
    const history = await api.as(admin).get(`/centers/${firstCenterId}/history`);

    expect(changed.status).toBe(200);
    expect(history.status).toBe(200);
    expect((history.body as { versions: unknown[] }).versions).toHaveLength(2);
  });

  // 404 rather than 403, so nobody learns which Centers exist.
  test("an Admin can't read or change another Center in the same Organization", async () => {
    const { owner, orgId, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);
    const otherCenterId = deviceId(clock);
    await api.as(owner).post(`/organizations/${orgId}/centers`, {
      id: otherCenterId, name: "Little Oaks Uptown", currency: "CAD", timezone: "America/Vancouver",
    });

    expect((await api.as(admin).get(`/centers/${otherCenterId}`)).status).toBe(404);
    expect((await api.as(admin).get(`/centers/${otherCenterId}/history`)).status).toBe(404);
    expect((await api.as(admin).patch(`/centers/${otherCenterId}`, timezoneChange())).status).toBe(404);
    expect((await api.as(admin).get(`/organizations/${orgId}/centers`)).status).toBe(404);
  });

  test("an Admin can't read or change another Organization's Center", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);
    const other = await ownerWithOrganization();

    expect((await api.as(admin).get(`/centers/${other.firstCenterId}`)).status).toBe(404);
    expect((await api.as(admin).get(`/centers/${other.firstCenterId}/history`)).status).toBe(404);
    expect((await api.as(admin).patch(`/centers/${other.firstCenterId}`, timezoneChange())).status).toBe(404);
  });

  test("an Admin can't invite people; only an Owner appoints Admins", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);
    const friend = await signedUp(api, "Fran Friend");

    const response = await invite(admin, firstCenterId, friend);

    expect(response.status).toBe(404);
  });
});

describe("a Center's Admins", () => {
  test("an Owner can also be their Center's Admin", async () => {
    const { owner, orgId, firstCenterId } = await ownerWithOrganization();

    const appointed = await api.as(owner).put(`/centers/${firstCenterId}/admins/${owner.personId}`, {});

    expect(appointed.status).toBe(200);
    expect(appointed.body).toEqual({ personId: owner.personId, name: "Ana Owner", email: owner.email });
    const me = await api.as(owner).get("/me");
    expect(me.body).toMatchObject({
      organizations: [{ id: orgId, roles: ["Owner"] }],
      centers: [{ id: firstCenterId, name: "Little Oaks Downtown", orgId, roles: ["Admin"] }],
    });
  });

  test("an Owner appoints anyone else by inviting them", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const someoneElse = await signedUp(api, "Sam Stranger");

    const response = await api.as(owner).put(`/centers/${firstCenterId}/admins/${someoneElse.personId}`, {});

    expect(response.status).toBe(400);
    expect((await api.as(someoneElse).get(`/centers/${firstCenterId}`)).status).toBe(404);
  });

  test("an Owner sees the Center's Admins", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId, "Ari Admin");
    await api.as(owner).put(`/centers/${firstCenterId}/admins/${owner.personId}`, {});

    const list = await api.as(owner).get(`/centers/${firstCenterId}/admins`);

    expect(list.status).toBe(200);
    expect((list.body as { admins: unknown[] }).admins).toEqual(expect.arrayContaining([
      { personId: admin.personId, name: "Ari Admin", email: admin.email },
      { personId: owner.personId, name: "Ana Owner", email: owner.email },
    ]));
    expect((list.body as { admins: unknown[] }).admins).toHaveLength(2);
  });

  test("an invited Admin sees the Center in their list of Centers", async () => {
    const { owner, orgId, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);

    const me = await api.as(admin).get("/me");

    expect(me.body).toMatchObject({
      organizations: [],
      centers: [{ id: firstCenterId, name: "Little Oaks Downtown", orgId, roles: ["Admin"] }],
    });
  });
});

describe("removing an Admin", () => {
  test("a removed Admin loses access to the Center on their next request", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);

    const removed = await api.as(owner).delete(`/centers/${firstCenterId}/admins/${admin.personId}`);

    expect(removed.status).toBe(204);
    expect((await api.as(admin).get(`/centers/${firstCenterId}`)).status).toBe(404);
    expect((await api.as(admin).get("/me")).body).toMatchObject({ centers: [] });
    expect((await api.as(owner).get(`/centers/${firstCenterId}/admins`)).body).toEqual({ admins: [] });
  });

  test("an Owner who stops being the Admin is still the Owner", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    await api.as(owner).put(`/centers/${firstCenterId}/admins/${owner.personId}`, {});

    const removed = await api.as(owner).delete(`/centers/${firstCenterId}/admins/${owner.personId}`);

    expect(removed.status).toBe(204);
    expect((await api.as(owner).get(`/centers/${firstCenterId}`)).status).toBe(200);
  });

  // The app retries if it loses the response.
  test("removing someone who isn't an Admin changes nothing", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);
    await api.as(owner).delete(`/centers/${firstCenterId}/admins/${admin.personId}`);

    const again = await api.as(owner).delete(`/centers/${firstCenterId}/admins/${admin.personId}`);

    expect(again.status).toBe(204);
  });

  test("only an Owner removes Admins", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId, "Ari Admin");
    const coAdmin = await appointedAdmin(owner, firstCenterId, "Cam Coadmin");

    const response = await api.as(admin).delete(`/centers/${firstCenterId}/admins/${coAdmin.personId}`);

    expect(response.status).toBe(404);
    expect((await api.as(coAdmin).get(`/centers/${firstCenterId}`)).status).toBe(200);
  });

  test("a removed Admin can't get back in with their old invitation", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await signedUp(api, "Ari Admin");
    const { token } = (await invite(owner, firstCenterId, admin)).body as { token: string };
    await api.as(admin).post(`/centers/${firstCenterId}/invitations/accept`, { token });
    await api.as(owner).delete(`/centers/${firstCenterId}/admins/${admin.personId}`);

    const again = await api.as(admin).post(`/centers/${firstCenterId}/invitations/accept`, { token });

    expect(again.status).toBe(404);
    expect((await api.as(admin).get(`/centers/${firstCenterId}`)).status).toBe(404);
  });

  test("removing a person cancels the invitations they haven't accepted yet", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);
    const { token: unused } = (await invite(owner, firstCenterId, admin)).body as { token: string };
    const someoneElse = await signedUp(api, "Sam Stranger");
    const { token: theirs } = (await invite(owner, firstCenterId, someoneElse)).body as { token: string };

    await api.as(owner).delete(`/centers/${firstCenterId}/admins/${admin.personId}`);

    expect((await api.as(admin).post(`/centers/${firstCenterId}/invitations/accept`, { token: unused })).status).toBe(404);
    expect((await api.as(admin).get(`/centers/${firstCenterId}`)).status).toBe(404);
    expect((await api.as(someoneElse).post(`/centers/${firstCenterId}/invitations/accept`, { token: theirs })).status).toBe(200);
  });

  test("an Admin who accepts a new invitation after being removed is an Admin again", async () => {
    const { owner, firstCenterId } = await ownerWithOrganization();
    const admin = await appointedAdmin(owner, firstCenterId);
    await api.as(owner).delete(`/centers/${firstCenterId}/admins/${admin.personId}`);
    const { token } = (await invite(owner, firstCenterId, admin)).body as { token: string };

    await api.as(admin).post(`/centers/${firstCenterId}/invitations/accept`, { token });

    expect((await api.as(admin).get(`/centers/${firstCenterId}`)).status).toBe(200);
  });
});
