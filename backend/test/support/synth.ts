import { fileURLToPath } from "node:url";
import { App } from "aws-cdk-lib";
import { Template } from "aws-cdk-lib/assertions";
import { createStageStack, type Stage } from "../../infra/stage.js";

// Building a stage needs no AWS access. Bundling is skipped, and a stand-in
// Admin web build is used, because these tests only check what each stage
// would deploy, not the Lambda code or the app.
const adminWebDir = fileURLToPath(new URL("./adminWebBuild", import.meta.url));

export function synth(stage: Stage) {
  const app = new App({ context: { "aws:cdk:bundling-stacks": [] } });
  const stack = createStageStack(app, stage, { account: "111111111111", adminWebDir });
  return { stack, template: Template.fromStack(stack) };
}
