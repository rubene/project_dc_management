import type { Browser, Page } from "@playwright/test";
import { expect } from "@playwright/test";
import type { Login } from "./logins.js";

// Steps through the Admin web app, as a person would. Flutter draws on a
// canvas, so fields and buttons are found by their labels in the
// accessibility tree, which Flutter builds once its hidden "Enable
// accessibility" button is pressed.

// Fills in a form's fields in order, typing key by key as a person would.
// Focus moves to the next field with Tab: moving it from the page instead
// makes Flutter clear the field just left. Flutter sets a field up a moment
// after it's focused and can drop the first keys, so a field that didn't get
// all of its text is cleared and typed again.
export async function enter(page: Page, fields: Record<string, string>) {
  let first = true;
  for (const [label, text] of Object.entries(fields)) {
    const field = page.getByRole("textbox", { name: label });
    if (first) await field.focus();
    else await page.keyboard.press("Tab");
    first = false;
    await expect(async () => {
      await page.keyboard.press("ControlOrMeta+A");
      await page.keyboard.press("Backspace");
      await page.keyboard.type(text);
      await expect(field).toHaveValue(text, { timeout: 1_000 });
    }).toPass();
  }
}

// Flutter 3.35 throws on the pointer events of a click while the
// accessibility tree is on, and ignores the click. The click event alone, as
// a screen reader sends it, works. A tap while a screen is still sliding in
// can be lost, so when `then` is given it taps again until that shows.
export async function tap(page: Page, label: string, { then }: { then?: string | RegExp } = {}) {
  const button = page.getByRole("button", { name: label, exact: true });
  if (!then) return button.dispatchEvent("click");
  await expect(async () => {
    await button.dispatchEvent("click", undefined, { timeout: 2_000 });
    await expect(shown(page, then)).toBeVisible({ timeout: 5_000 });
  }).toPass();
}

/**
 * Text on the screen. A list row is a group named by all its lines, such as
 * "Ari Admin" and their email, so its first line is found by that name.
 */
export function shown(page: Page, text: string | RegExp) {
  return page.getByText(text).or(page.getByLabel(text)).filter({ visible: true }).first();
}

/** Opens the app in a browser of its own, so each person has their own session. */
export async function openApp(browser: Browser, path = "/") {
  const page = await (await browser.newContext()).newPage();
  await page.goto(path);
  await page.locator("flt-semantics-placeholder").dispatchEvent("click");
  return page;
}

export async function signIn(page: Page, { email, password }: Login) {
  await expect(shown(page, "Sign in to DC Management")).toBeVisible();
  await enter(page, { Email: email, Password: password });
  await tap(page, "Sign in");
}

/** A new login's first visit: sign in, give a name, and set up an Organization with one Center. */
export async function setUpOrganization(page: Page, login: Login, { name, organization, center }: { name: string; organization: string; center: string }) {
  await signIn(page, login);
  await giveName(page, name);
  await expect(shown(page, "Set up your Organization")).toBeVisible();
  await enter(page, { "Organization name": organization, "First Center name": center });
  await tap(page, "Create Organization", { then: center });
}

/** The name a new login gives the first time they sign in. */
export async function giveName(page: Page, name: string) {
  await expect(shown(page, "What's your name?")).toBeVisible();
  await enter(page, { "Your name": name });
  await tap(page, "Continue");
}
