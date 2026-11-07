// The one main table that holds operational data (see the v1 spec, "Data").
// Shared by the CDK stack and the DynamoDB Local test setup so both create
// the same table.
export const mainTableKeys = {
  partitionKey: "PK",
  sortKey: "SK",
} as const;
