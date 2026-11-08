# Architecture

This page shows what's built so far. It grows as each ticket adds to the system; the full v1 plan is in the spec (issue #3) and the reasoning in [`adr/`](adr/).

```mermaid
flowchart LR
  mobile["Mobile app<br/>(Flutter, iOS and Android)"] -->|HTTPS, per api/openapi.yaml| apigw["API Gateway<br/>REST API, stage v1"]
  browser["Admin web app<br/>(Flutter web, in the browser)"] --> cf["CloudFront<br/>Admin web distribution"]
  cf -->|"/*"| bucket[("S3<br/>Admin web build, private")]
  cf -->|"/v1/*"| apigw
  check["Deployed check<br/>(after each deploy)"] --> apigw
  check --> cf
  apigw -->|every path| fn["API Lambda<br/>Node 24, arm64"]
  fn --> table[("Main table<br/>DynamoDB")]
  fn --> logs["CloudWatch Logs"]
```

Everything runs in `us-west-2` ([ADR 0006](adr/0006-single-region-us-west-2.md)), with one CloudFormation stack per stage: `dc-dev`, `dc-staging`, `dc-prod`.

## The API

- **One contract.** [`api/openapi.yaml`](../api/openapi.yaml) describes every operation. The apps' Dart client in `packages/api_client` is generated from it by `packages/generate-api-client.sh` (openapi-generator's `dart` generator, run in Docker) and committed. Every API test checks responses against it, and a path it doesn't describe must return its `Error` response with a 404.
- **One Lambda.** API Gateway sends every request to a single API Lambda, which routes by method and path (`backend/src/app.ts`). Adding an operation means adding a route and documenting it in the OpenAPI definition. Scheduled jobs, Step Functions steps and the Assistant will get their own functions that reuse the same app code ([ADR 0009](adr/0009-one-lambda-serves-the-whole-api.md)).
- **Dependencies are passed in.** The app is built from its dependencies (`createApp({ clock, db, tableName })`). The Lambda passes the real ones; tests pass DynamoDB Local and fakes.
- **Time comes from the `Clock`.** Business rules call `clock.now()`, never `new Date()`, so tests can set the time.

## The apps

- **Mobile** (`apps/mobile`): one Flutter app for Staff and Guardians. It calls API Gateway directly, at the URL given with `--dart-define=API_URL=…` at build time.
- **Admin web** (`apps/admin_web`): a Flutter web app. Its build is uploaded on deploy to a private S3 bucket that blocks all public access. Only the stage's CloudFront distribution can read it, through Origin Access Control.
- **The API on the same address.** The Admin web distribution also passes `/v1/*` to API Gateway, uncached. The web app calls its own origin, so the API needs no CORS and no list of allowed origins.
- **Shared code.** Both apps use the generated client and the shared UI library in `packages/ui`, which holds the theme and shared screens.

## Data

One main DynamoDB table with a generic `PK`/`SK` key holds the operational data. [`data-model.md`](data-model.md) lists every v1 query and the key layout that serves them. Every Center record's key starts with the Center, corrected records keep append-only history, and records are ready for offline use (ADR 0004). Changes are exported to S3 for Athena. In staging and production the table is retained if the stack is deleted, with point-in-time recovery and deletion protection on. Dev has neither, since it only holds made-up data.

## Stages

Each stage's settings live in `backend/infra/stage.ts`. The account comes from the AWS profile used to deploy, so staging and production are created the same way as dev, each in its own account.

## Tests

| Group | Command | What it checks |
|---|---|---|
| `api` | `npm test` | The API through the real handler, in-process, against DynamoDB Local in Docker. Responses are checked against OpenAPI. |
| `infra` | `npm test` | Each stage can be built from settings alone, in `us-west-2` |
| `infra` (Admin web) | `npm test` | The Admin web bucket is private and readable only by CloudFront, and `/v1/*` goes to the API, uncached |
| `deployed` | `npm run check:deployed` | A deployed stage answers `/health` and can read its table. The Admin web app is served through CloudFront, its address reaches the API, and the bucket refuses direct requests |
| App screens | `flutter test` in each app | Each app's screens, with the real generated client talking to a fake API |

Fakes for outside systems are added only when a ticket first needs them. So far there's one: the clock (`backend/test/support/fakeClock.ts`).
