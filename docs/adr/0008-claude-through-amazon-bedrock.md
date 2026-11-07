# Claude through Amazon Bedrock

The Assistant calls Claude through Amazon Bedrock, using a US cross-region inference profile, so data processing stays with AWS and within the US, and Lambdas sign in with IAM. This was chosen over Claude Platform on AWS and Anthropic's API, which get new Claude features sooner but have Anthropic process the data. Bedrock can lag behind on some newer Claude features, and switching later is possible because the Anthropic SDK has a client for each option.
