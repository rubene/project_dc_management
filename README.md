# DC Management

A lower-priced daycare management service for independent Centers in the US and Canada. See [`docs/v1-scope.md`](docs/v1-scope.md) for what v1 covers, [`GLOSSARY.md`](GLOSSARY.md) for terms, and [`docs/adr/`](docs/adr/) for the reasoning behind hard-to-reverse decisions.

## Repo layout

| Path | What's there |
|---|---|
| `api/openapi.yaml` | The OpenAPI definition: the single contract between the backend and the apps |
| `backend/src/` | The API, running on Lambda in TypeScript |
| `backend/infra/` | All infrastructure, in CDK (TypeScript) |
| `backend/test/` | API tests, infrastructure tests and the deployed check |
| `docs/` | [Architecture](docs/architecture.md), [runbook](docs/runbook.md), ADRs and v1 scope |

## Set up

You need:

- Node from [`.nvmrc`](.nvmrc): `nvm install && nvm use`
- Docker running, for DynamoDB Local
- For deploying: the AWS CLI with a `project_dc` profile for the dev account

```sh
cd backend
npm install
npm test          # API tests against DynamoDB Local, plus CDK stage tests
npm run typecheck
```

## Deploy

```sh
cd backend
npm run deploy:dev   # deploys to us-west-2, then runs the deployed check
```

Staging and production are created the same way from another account's profile, with no code changes:

```sh
npx cdk deploy -c stage=staging --profile <staging-profile> --outputs-file cdk-outputs.staging.json
STAGE=staging npm run check:deployed
```

Only the dev account exists until v1 is code complete, and it only ever holds made-up data. If something goes wrong, see the [runbook](docs/runbook.md).
