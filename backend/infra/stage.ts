import { fileURLToPath } from "node:url";
import { CfnOutput, Duration, RemovalPolicy, Stack, Tags } from "aws-cdk-lib";
import { LambdaRestApi } from "aws-cdk-lib/aws-apigateway";
import { AttributeType, Billing, TableV2 } from "aws-cdk-lib/aws-dynamodb";
import { Architecture, Runtime } from "aws-cdk-lib/aws-lambda";
import { NodejsFunction } from "aws-cdk-lib/aws-lambda-nodejs";
import { LogGroup, RetentionDays } from "aws-cdk-lib/aws-logs";
import type { Construct } from "constructs";
import { mainTableKeys } from "../src/mainTable.js";

// Every environment runs in one region (ADR 0006).
export const region = "us-west-2";

type StageSettings = {
  // Keep the table and logs if the stack is deleted. The dev account only
  // ever holds made-up data, so dev can be torn down freely.
  retainData: boolean;
  logRetention: RetentionDays;
};

const stages: Record<string, StageSettings> = {
  dev: { retainData: false, logRetention: RetentionDays.TWO_WEEKS },
  staging: { retainData: true, logRetention: RetentionDays.ONE_MONTH },
  prod: { retainData: true, logRetention: RetentionDays.ONE_YEAR },
};

export function createStage(scope: Construct, stage: string, { account }: { account: string }) {
  const settings = stages[stage];
  if (!settings) {
    throw new Error(`Unknown stage "${stage}". Expected one of: ${Object.keys(stages).join(", ")}`);
  }
  const removalPolicy = settings.retainData ? RemovalPolicy.RETAIN : RemovalPolicy.DESTROY;

  const stack = new Stack(scope, `dc-${stage}`, {
    stackName: `dc-${stage}`,
    env: { account, region },
  });
  Tags.of(stack).add("project", "dc-management");
  Tags.of(stack).add("stage", stage);

  const table = new TableV2(stack, "MainTable", {
    partitionKey: { name: mainTableKeys.partitionKey, type: AttributeType.STRING },
    sortKey: { name: mainTableKeys.sortKey, type: AttributeType.STRING },
    billing: Billing.onDemand(),
    pointInTimeRecoverySpecification: { pointInTimeRecoveryEnabled: settings.retainData },
    deletionProtection: settings.retainData,
    removalPolicy,
  });

  const apiFunction = new NodejsFunction(stack, "ApiFunction", {
    entry: fileURLToPath(new URL("../src/lambda.ts", import.meta.url)),
    runtime: Runtime.NODEJS_24_X,
    architecture: Architecture.ARM_64,
    memorySize: 512,
    timeout: Duration.seconds(10),
    environment: { TABLE_NAME: table.tableName },
    logGroup: new LogGroup(stack, "ApiLogs", {
      logGroupName: `/dc/${stage}/api`,
      retention: settings.logRetention,
      removalPolicy,
    }),
  });
  table.grantReadWriteData(apiFunction);

  const api = new LambdaRestApi(stack, "Api", {
    handler: apiFunction,
    restApiName: `dc-${stage}`,
    deployOptions: { stageName: "v1" },
  });

  new CfnOutput(stack, "ApiUrl", { value: api.url });

  return stack;
}
