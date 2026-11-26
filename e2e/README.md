# Browser tests

Playwright tests that click through the Admin web app on a deployed stage
(dev by default), as Owners and Admins would. They cover a few flows end to
end; the edge cases stay in the backend API tests and the Flutter widget tests.

Each test makes throwaway logins straight in the stage's Cognito user pool,
with verified emails, and deletes them when it ends. What they did in the app
stays in the stage's table, under unique `e2e-…@example.test` emails. Creating
an account through the app isn't covered here, since a test can't read the
code Cognito emails.

## Running

Deploy the stage first (`cd backend && npm run deploy:dev`). The tests read its
URL and user pool from `backend/cdk-outputs.dev.json`, or from `ADMIN_WEB_URL`
and `USER_POOL_ID`, and use the `project_dc` AWS profile (or `AWS_PROFILE`).

```sh
cd e2e
npm install
npx playwright install chromium
npm test              # headless
npm run test:ui       # watch each step, and replay it
npm run test:headed   # in a visible browser
npx playwright show-report
```

A failed test keeps a trace and a video, under `test-results/`.

The tests press Flutter's hidden "Enable accessibility" button, which builds
the accessibility tree they find fields and buttons in by their labels.
