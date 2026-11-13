import { Match } from "aws-cdk-lib/assertions";
import { CachePolicy } from "aws-cdk-lib/aws-cloudfront";
import { describe, expect, test } from "vitest";
import { parseStage, stageNames } from "../../infra/stage.js";
import { synth } from "../support/synth.js";

type PolicyStatement = {
  Effect: string;
  Principal: unknown;
  Action: string | string[];
  Condition?: { StringEquals?: Record<string, unknown> };
};

describe.each(stageNames)("the %s stage", (stage) => {
  test("is created in us-west-2 from settings alone", () => {
    const { stack } = synth(stage);

    expect(stack.region).toBe("us-west-2");
  });

  // Short-lived items such as invitations set `ttl` (docs/data-model.md).
  test("lets DynamoDB delete expired items from the main table", () => {
    const { template } = synth(stage);

    template.hasResourceProperties("AWS::DynamoDB::GlobalTable", {
      TimeToLiveSpecification: { AttributeName: "ttl", Enabled: true },
    });
  });

  test("publishes the API's URL for the deployed check", () => {
    const { template } = synth(stage);

    template.hasOutput("ApiUrl", {});
  });

  test("keeps the Admin web app's bucket private, readable only by CloudFront", () => {
    const { template } = synth(stage);

    template.resourceCountIs("AWS::S3::Bucket", 1);
    template.hasResourceProperties("AWS::S3::Bucket", {
      PublicAccessBlockConfiguration: {
        BlockPublicAcls: true,
        BlockPublicPolicy: true,
        IgnorePublicAcls: true,
        RestrictPublicBuckets: true,
      },
    });

    const policies = Object.values(template.findResources("AWS::S3::BucketPolicy"));
    expect(policies).toHaveLength(1);
    const allows: PolicyStatement[] = policies[0]!.Properties.PolicyDocument.Statement.filter(
      (statement: PolicyStatement) => statement.Effect === "Allow",
    );

    // Nothing is granted to everyone.
    for (const allow of allows) {
      expect(allow.Principal).not.toBe("*");
      expect(allow.Principal).not.toEqual({ AWS: "*" });
    }

    // Reading files is granted only to this stage's CloudFront distribution.
    const reads = allows.filter((allow) => [allow.Action].flat().includes("s3:GetObject"));
    expect(reads).toHaveLength(1);
    expect(reads[0]!.Principal).toEqual({ Service: "cloudfront.amazonaws.com" });
    expect(Object.keys(reads[0]!.Condition?.StringEquals ?? {})).toEqual(["AWS:SourceArn"]);
  });

  test("serves the Admin web app and the API from one CloudFront address", () => {
    const { template } = synth(stage);

    template.hasOutput("AdminWebUrl", {});
    template.hasResourceProperties("AWS::CloudFront::Distribution", {
      DistributionConfig: Match.objectLike({
        CacheBehaviors: [
          Match.objectLike({
            PathPattern: "/v1/*",
            AllowedMethods: ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"],
            // Answers come from the API on every request, never a cache.
            CachePolicyId: CachePolicy.CACHING_DISABLED.cachePolicyId,
          }),
        ],
      }),
    });
  });
});

test("an unknown stage is refused", () => {
  expect(() => parseStage("qa")).toThrow(/Unknown stage "qa"/);
});
