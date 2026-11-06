# Single region: us-west-2

All environments run in one AWS region, `us-west-2`, chosen by the project owner over `ca-central-1`, so Canadian families' data is stored in the US. Moving DynamoDB data and Cognito users between regions later would be painful, and the privacy review should confirm what Canadian Centers need to disclose. Only a dev account exists until v1 is code complete, and the CDK must be able to create separate staging and production accounts in the same way.
