import { defineConfig, devices } from "@playwright/test";
import { adminWebUrl } from "./support/stage.js";

// Runs against a deployed stage (dev unless STAGE says otherwise), signed in
// as throwaway logins the tests create. See README.md.
export default defineConfig({
  testDir: "tests",
  // Each step waits on Cognito and the API, so allow for a slow round trip.
  timeout: 90_000,
  expect: { timeout: 15_000 },
  // Flutter draws each page on the CPU in headless Chrome, and pages drawn at
  // once slow each other enough to drop taps and keys. One at a time is steady.
  workers: 1,
  reporter: [["list"], ["html", { open: "never" }]],
  use: {
    baseURL: adminWebUrl(),
    // The timezone a new Center is offered, as in the widget tests.
    timezoneId: "America/Vancouver",
    trace: "retain-on-failure",
    video: "retain-on-failure",
    screenshot: "only-on-failure",
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
});
