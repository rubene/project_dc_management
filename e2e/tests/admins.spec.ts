import type { Page } from "@playwright/test";
import { expect, test } from "../support/logins.js";
import { enter, giveName, openApp, setUpOrganization, shown, signIn, tap } from "../support/app.js";

// Issue #9: an Owner appoints an Admin. Each test signs in as new logins, so
// it starts from an empty Organization.

const center = "Little Oaks Downtown";

/** From the Owner's list of Centers, invites an Admin and gives back the link to send them. */
async function invite(owner: Page, name: string, email: string) {
  await tap(owner, center, { then: /^Admins$/ });
  await tap(owner, "Invite an Admin", { then: `Invite an Admin to ${center}` });
  await enter(owner, { "Their name": name, "Their email": email });
  await tap(owner, "Create invitation", { then: `Send ${name} this link` });
  const link = await owner.getByText(/^https:.*invitation=/).textContent();
  expect(link).toMatch(/\?center=.+&invitation=/);
  return link!;
}

test("an Owner invites an Admin, who accepts and runs the Center, and the Owner removes them", async ({ browser, logins }) => {
  const [ownerLogin, adminLogin] = await Promise.all([logins.make("ana"), logins.make("ari")]);
  const owner = await openApp(browser);
  await setUpOrganization(owner, ownerLogin, { name: "Ana Owner", organization: "Little Oaks", center });
  const link = await invite(owner, "Ari Admin", adminLogin.email);

  // Ari opens the link in their own browser, already having a login.
  const admin = await openApp(browser, link);
  await expect(shown(admin, "You've been invited to DC Management")).toBeVisible();
  await tap(admin, "I already have an account", { then: "Sign in to DC Management" });
  await signIn(admin, adminLogin);
  await giveName(admin, "Ari Admin");
  await expect(shown(admin, "You are an Admin here")).toBeVisible();
  await expect(shown(admin, center)).toBeVisible();

  // Back on the Owner's page, Ari is listed once the Center is opened again.
  await tap(owner, "Done", { then: /^Admins$/ });
  await tap(owner, "Back", { then: /^Centers$/ });
  await tap(owner, center, { then: /^Ari Admin/ });
  await tap(owner, "Remove Ari Admin", { then: `Remove Ari Admin as an Admin of ${center}?` });
  await tap(owner, "Remove", { then: "No Admins yet" });
});

test("an invitation link used with another email is refused", async ({ browser, logins }) => {
  const [ownerLogin, strangerLogin] = await Promise.all([logins.make("ana"), logins.make("sam")]);
  const owner = await openApp(browser);
  await setUpOrganization(owner, ownerLogin, { name: "Ana Owner", organization: "Little Oaks", center });
  const link = await invite(owner, "Ari Admin", "e2e-nobody-ari@example.test");

  const stranger = await openApp(browser, link);
  await tap(stranger, "I already have an account", { then: "Sign in to DC Management" });
  await signIn(stranger, strangerLogin);
  await giveName(stranger, "Sam Stranger");

  await expect(shown(stranger, "This invitation can't be used")).toBeVisible();
  await expect(shown(stranger, /This invitation is for a different email address/)).toBeVisible();
  await tap(stranger, "Continue without it", { then: "Set up your Organization" });
});

test("an Owner makes themselves their Center's Admin too", async ({ browser, logins }) => {
  const ownerLogin = await logins.make("ana");
  const owner = await openApp(browser);
  await setUpOrganization(owner, ownerLogin, { name: "Ana Owner", organization: "Little Oaks", center });
  await tap(owner, center, { then: "No Admins yet" });

  await tap(owner, "Make me an Admin here too", { then: "Ana Owner (you)" });

  await expect(owner.getByRole("button", { name: "Make me an Admin here too" })).toHaveCount(0);
});
