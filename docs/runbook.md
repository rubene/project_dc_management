# Runbook

How to deploy and fix common problems. Commands run from `backend/`.

## Deploy dev

```sh
npm run deploy:dev
```

This deploys the `dc-dev` stack to `us-west-2` with the `project_dc` profile, writes the API's URL to `cdk-outputs.dev.json`, and then runs the deployed check.

## Check a deployed stage

```sh
npm run check:deployed                 # dev
STAGE=staging npm run check:deployed   # another stage, after deploying it with --outputs-file cdk-outputs.staging.json
```

You can also call it by hand: `curl <ApiUrl>health`. A healthy API returns `{"status":"ok","database":"ok","time":"…"}`.

## Common problems

### `npm test` fails with "Cannot connect to the Docker daemon"

The API tests start DynamoDB Local in Docker. Start Docker Desktop and run the tests again.

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

### Removing the dev stack

```sh
npx cdk destroy -c stage=dev --profile project_dc
```

Dev's table and logs are deleted with it. Staging and production keep their table, which has deletion protection on.
