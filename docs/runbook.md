# Runbook

How to deploy and fix common problems. Commands run from `backend/`.

## Deploy dev

```sh
npm run deploy:dev
```

This builds the Admin web app (`flutter build web`), deploys the `dc-dev` stack to `us-west-2` with the `project_dc` profile, writes the API's and Admin web app's URLs to `cdk-outputs.dev.json`, and then runs the deployed check. The Admin web app is at the `AdminWebUrl` output.

## Check a deployed stage

```sh
npm run check:deployed                 # dev
STAGE=staging npm run check:deployed   # another stage, after deploying it with --outputs-file cdk-outputs.staging.json
```

Without a local `cdk-outputs.<stage>.json` (a fresh checkout, or CI), pass the API's URL instead:

```sh
API_URL=https://<api-id>.execute-api.us-west-2.amazonaws.com/v1/ \
ADMIN_WEB_URL=https://<distribution>.cloudfront.net/ \
ADMIN_WEB_BUCKET_URL=https://<bucket>.s3.us-west-2.amazonaws.com/ \
npm run check:deployed
```

You can also call it by hand: `curl <ApiUrl>health`. A healthy API returns `{"status":"ok","database":"ok","time":"…"}`. Every other path needs a login, so `curl <ApiUrl>me` returns 401 `{"message":"Unauthorized"}`.

## Logins

Each stage has a Cognito user pool, `dc-<stage>-logins`. Its ID and the apps' client ID are the `UserPoolId` and `AppClientId` outputs. People sign up with their email, and MFA with an authenticator app is optional (#51). Roles are never in Cognito: they're in DynamoDB.

The apps' client signs in only with SRP, which the Admin web app does through Amplify. A request sends the ID token as `Authorization: Bearer <token>`. After signing up with `PUT /me`, the app gets new tokens, because only tokens issued after sign-up carry the `personId` claim.

## Common problems

### Every request gets 403 "Sign up first", even after signing up

The token was issued before `PUT /me`. Get a new one (sign in again, or refresh). If new tokens still lack `personId`, check the `/dc/<stage>/pre-token-generation` logs: a database error there issues tokens without the claim rather than blocking the login. The trigger must be connected as version 2 (the infra test checks it).

### `npm test` fails with "Cannot connect to the Docker daemon"

The API tests start DynamoDB Local in Docker. Start Docker Desktop and run the tests again.

### `npm test` fails with "DynamoDB Local didn't become ready within 30 seconds"

The test setup started DynamoDB Local but couldn't create the test table in time. The error's `cause` shows the last failure. Usually Docker is short of resources: check that `docker run --rm amazon/dynamodb-local:3.3.2 -version` runs quickly, give Docker Desktop more memory if not, and run the tests again.

### A test run was killed and left DynamoDB Local running

```sh
docker ps --filter ancestor=amazon/dynamodb-local:3.3.2 -q | xargs docker stop
```

### `npm` or `node` isn't found, or the wrong version runs

Run `nvm install && nvm use` from the repo root to use the version in `.nvmrc`.

### Deploy fails with "No AWS account found" or expired credentials

Check the profile works: `aws sts get-caller-identity --profile project_dc`. If you use SSO, sign in again with `aws sso login --profile project_dc`.

### Deploy fails with "has not been bootstrapped" or "SSM parameter /cdk-bootstrap/... not found"

The account needs CDK's bootstrap stack in `us-west-2`. The profile's default region doesn't matter, but bootstrapping must name the region:

```sh
npx cdk bootstrap aws://<account-id>/us-west-2 --profile project_dc
```

### `/health` returns 503 `{"status":"unavailable","database":"unavailable"}`

The Lambda is running but can't read the main table. Look at the API Lambda's logs for the error, which comes after the message "Health check couldn't read the main table":

```sh
aws logs tail /dc/dev/api --since 15m --region us-west-2 --profile project_dc
```

`AccessDeniedException` means the Lambda lacks permission on the table, and `ResourceNotFoundException` means `TABLE_NAME` points at a table that doesn't exist. Both mean the deployed stack doesn't match the code; deploy again.

### `/health` returns 502 or `{"message": "Internal server error"}`

The Lambda crashed before it could respond, often at startup (for example, `TABLE_NAME is not set`). Look at its logs as above.

### Synth or deploy fails with "No Admin web build found"

The stack uploads `apps/admin_web/build/web`. Build it with `npm run build:admin-web`. `npm run deploy:dev` does this for you.

### The Admin web app shows an old version after a deploy

The deploy clears CloudFront's cache for the app. Reload without the browser cache. If it persists, check the `AdminWebDeployment` custom resource's logs in CloudWatch.

### The Admin web app says "Can't reach the API"

Open `<AdminWebUrl>v1/health`. If that fails while `<ApiUrl>health` works, the distribution's `/v1/*` behavior isn't reaching API Gateway; deploy again.

### iOS build fails with "Failed to launch AssetCatalogSimulatorAgent"

Xcode is too old for the installed macOS. Flutter 3.35 needs Xcode 15 or later; update Xcode and run `flutter doctor`.

### Removing the dev stack

```sh
npx cdk destroy -c stage=dev --profile project_dc
```

Dev's table, logs and Admin web bucket are deleted with it. The Admin web bucket is deleted with the stack in every stage, since it only holds the app's build. Staging and production keep their table, which has deletion protection on.
