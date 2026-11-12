# DC Management

A lower-priced daycare management service for independent Centers in the US and Canada. See [`docs/v1-scope.md`](docs/v1-scope.md) for what v1 covers, [`GLOSSARY.md`](GLOSSARY.md) for terms, and [`docs/adr/`](docs/adr/) for the reasoning behind hard-to-reverse decisions.

## Repo layout

| Path | What's there |
|---|---|
| `api/openapi.yaml` | The OpenAPI definition: the single contract between the backend and the apps |
| `backend/src/` | The API, running on Lambda in TypeScript |
| `backend/infra/` | All infrastructure, in CDK (TypeScript) |
| `backend/test/` | API tests, infrastructure tests and the deployed check |
| `apps/mobile/` | The Flutter app for Staff and Guardians, on iOS and Android |
| `apps/admin_web/` | The Flutter web app for Admins, hosted on S3 behind CloudFront |
| `packages/api_client/` | The Dart API client, generated from `api/openapi.yaml`. Don't edit it by hand |
| `packages/ui/` | The UI library both apps share |
| `docs/` | [Architecture](docs/architecture.md), [runbook](docs/runbook.md), ADRs and v1 scope |

## Set up

You need:

- Node from [`.nvmrc`](.nvmrc): `nvm install && nvm use`
- Docker running, for DynamoDB Local
- Flutter 3.35 or later, for the apps and for deploying (the deploy builds the Admin web app)
- For deploying: the AWS CLI with a `project_dc` profile for the dev account

```sh
cd backend
npm install
npm test          # API tests against DynamoDB Local, plus CDK stage tests
npm run typecheck
```

Apps:

```sh
cd apps/mobile      # or apps/admin_web
flutter pub get
flutter test        # screen tests against a fake API, using the generated client
flutter analyze
```

Run the mobile app on a simulator or emulator against a deployed API, using the `ApiUrl` from `backend/cdk-outputs.dev.json`:

```sh
cd apps/mobile
flutter run --dart-define=API_URL=https://<api-id>.execute-api.us-west-2.amazonaws.com/v1/
```

Run the Admin web app in Chrome against a deployed stage, using `ApiUrl`, `UserPoolId` and `AppClientId` from `backend/cdk-outputs.dev.json` (deployed, it reads them from `/config.json` instead):

```sh
cd apps/admin_web
flutter run -d chrome --dart-define=API_URL=https://<api-id>.execute-api.us-west-2.amazonaws.com/v1/ \
  --dart-define=USER_POOL_ID=<UserPoolId> --dart-define=APP_CLIENT_ID=<AppClientId>
```

Calling API Gateway directly from `localhost` needs CORS, which the API doesn't have, so for now sign-up and the Centers screens only work on the deployed app.

After changing `api/openapi.yaml`, regenerate the Dart client and commit the result (needs Docker):

```sh
packages/generate-api-client.sh
```

## Deploy

```sh
cd backend
npm run deploy:dev   # builds the Admin web app, deploys to us-west-2, then runs the deployed check
```

Staging and production are created the same way from another account's profile, with no code changes:

```sh
npm run build:admin-web
npx cdk deploy -c stage=staging --profile <staging-profile> --outputs-file cdk-outputs.staging.json
STAGE=staging npm run check:deployed
```

Only the dev account exists until v1 is code complete, and it only ever holds made-up data. If something goes wrong, see the [runbook](docs/runbook.md).
