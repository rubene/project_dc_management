import { App } from "aws-cdk-lib";
import { Template } from "aws-cdk-lib/assertions";
import { describe, expect, test } from "vitest";
import { createStage, stageNames } from "../../infra/stage.js";

// Building a stage needs no AWS access. Bundling is skipped because these
// tests only check what each stage would deploy, not the Lambda code.
function synth(stage: string) {
  const app = new App({ context: { "aws:cdk:bundling-stacks": [] } });
  const stack = createStage(app, stage, { account: "111111111111" });
  return { stack, template: Template.fromStack(stack) };
}

describe.each(stageNames)("the %s stage", (stage) => {
  test("is created in us-west-2 from settings alone", () => {
    const { stack } = synth(stage);

    expect(stack.region).toBe("us-west-2");
  });

  test("publishes the API's URL for the deployed check", () => {
    const { template } = synth(stage);

    template.hasOutput("ApiUrl", {});
  });
});

test("an unknown stage is refused", () => {
  expect(() => synth("qa")).toThrow(/Unknown stage "qa"/);
});
