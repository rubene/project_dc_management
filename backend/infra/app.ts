import { App } from "aws-cdk-lib";
import { createStage } from "./stage.js";

// Usage: npx cdk deploy -c stage=<dev|staging|prod> --profile <profile>
// The account comes from the AWS profile, so staging and production are
// created the same way as dev, each in its own account.
const app = new App();

const stage = app.node.tryGetContext("stage");
if (typeof stage !== "string") {
  throw new Error("Choose a stage, for example: npx cdk deploy -c stage=dev --profile project_dc");
}

const account = process.env.CDK_DEFAULT_ACCOUNT;
if (!account) {
  throw new Error("No AWS account found. Pass an AWS profile, for example --profile project_dc");
}

createStage(app, stage, { account });
