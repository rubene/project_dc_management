import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { createPreTokenGeneration } from "./preTokenGeneration.js";

// Cognito's pre-token-generation trigger gets its own function (ADR 0009),
// with read access to the main table only.
const tableName = process.env.TABLE_NAME;
if (!tableName) throw new Error("TABLE_NAME is not set");

export const handler = createPreTokenGeneration({
  db: DynamoDBDocumentClient.from(new DynamoDBClient({})),
  tableName,
});
