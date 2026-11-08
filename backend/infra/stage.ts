import { fileURLToPath } from "node:url";
import { CfnOutput, Duration, RemovalPolicy, Stack, Tags } from "aws-cdk-lib";
import { LambdaRestApi } from "aws-cdk-lib/aws-apigateway";
import {
  AllowedMethods,
  CachePolicy,
  Distribution,
  OriginProtocolPolicy,
  OriginRequestPolicy,
  ViewerProtocolPolicy,
} from "aws-cdk-lib/aws-cloudfront";
import { HttpOrigin, S3BucketOrigin } from "aws-cdk-lib/aws-cloudfront-origins";
import { AttributeType, Billing, TableV2 } from "aws-cdk-lib/aws-dynamodb";
import { Architecture, Runtime } from "aws-cdk-lib/aws-lambda";
import { NodejsFunction } from "aws-cdk-lib/aws-lambda-nodejs";
import { LogGroup, RetentionDays } from "aws-cdk-lib/aws-logs";
import { BlockPublicAccess, Bucket, BucketEncryption } from "aws-cdk-lib/aws-s3";
import { BucketDeployment, Source } from "aws-cdk-lib/aws-s3-deployment";
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

const stages = {
  dev: { retainData: false, logRetention: RetentionDays.TWO_WEEKS },
  staging: { retainData: true, logRetention: RetentionDays.ONE_MONTH },
  prod: { retainData: true, logRetention: RetentionDays.ONE_YEAR },
} satisfies Record<string, StageSettings>;

// A deploy environment, each in its own AWS account. Not to be confused with
// API Gateway's own stage, which is always "v1".
export type Stage = keyof typeof stages;
export const stageNames = Object.keys(stages) as Stage[];

export function stackName(stage: Stage) {
  return `dc-${stage}`;
}

// For stage names from outside the code, such as `-c stage=` or STAGE.
export function parseStage(name: string): Stage {
  if (!Object.hasOwn(stages, name)) {
    throw new Error(`Unknown stage "${name}". Expected one of: ${stageNames.join(", ")}`);
  }
  return name as Stage;
}

type StageStackProps = {
  account: string;
  // The Admin web app's release build (`flutter build web`), uploaded on deploy.
  adminWebDir: string;
};

export function createStageStack(scope: Construct, stage: Stage, { account, adminWebDir }: StageStackProps) {
  const settings: StageSettings = stages[stage];
  const name = stackName(stage);
  const removalPolicy = settings.retainData ? RemovalPolicy.RETAIN : RemovalPolicy.DESTROY;

  const stack = new Stack(scope, name, {
    stackName: name,
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
    restApiName: name,
    deployOptions: { stageName: "v1" },
  });

  new CfnOutput(stack, "ApiUrl", { value: api.url });

  // The Admin web app: a private bucket that only this stage's CloudFront
  // distribution can read, through Origin Access Control.
  const adminWebBucket = new Bucket(stack, "AdminWebBucket", {
    blockPublicAccess: BlockPublicAccess.BLOCK_ALL,
    encryption: BucketEncryption.S3_MANAGED,
    enforceSSL: true,
    removalPolicy: RemovalPolicy.DESTROY,
    autoDeleteObjects: true,
  });

  // The same distribution passes /v1/* to the API, so the app calls its own
  // origin and the API needs no CORS. The API's "v1" stage is part of the
  // path, so the origin is the API's host with no origin path.
  const adminWeb = new Distribution(stack, "AdminWeb", {
    comment: `${name} Admin web app`,
    defaultRootObject: "index.html",
    defaultBehavior: {
      origin: S3BucketOrigin.withOriginAccessControl(adminWebBucket),
      viewerProtocolPolicy: ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
    },
    additionalBehaviors: {
      "/v1/*": {
        origin: new HttpOrigin(`${api.restApiId}.execute-api.${region}.amazonaws.com`, {
          protocolPolicy: OriginProtocolPolicy.HTTPS_ONLY,
        }),
        viewerProtocolPolicy: ViewerProtocolPolicy.HTTPS_ONLY,
        allowedMethods: AllowedMethods.ALLOW_ALL,
        cachePolicy: CachePolicy.CACHING_DISABLED,
        // API Gateway needs its own Host header, so pass everything else.
        originRequestPolicy: OriginRequestPolicy.ALL_VIEWER_EXCEPT_HOST_HEADER,
      },
    },
  });

  new BucketDeployment(stack, "AdminWebDeployment", {
    sources: [Source.asset(adminWebDir)],
    destinationBucket: adminWebBucket,
    distribution: adminWeb,
  });

  new CfnOutput(stack, "AdminWebUrl", { value: `https://${adminWeb.distributionDomainName}/` });
  // Only for the deployed check, which confirms the bucket refuses direct requests.
  new CfnOutput(stack, "AdminWebBucketUrl", { value: `https://${adminWebBucket.bucketRegionalDomainName}/` });

  return stack;
}
