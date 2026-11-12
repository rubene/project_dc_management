import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { createPreTokenGeneration } from "./preTokenGeneration.js";

// Cognito's pre-token-generation trigger gets its own function, reusing the
// app code, as ADR 0009 does for other non-API entry points. It only needs to
// read the main table.
const tableName = process.env.TABLE_NAME;
if (!tableName) throw new Error("TABLE_NAME is not set");

export const handler = createPreTokenGeneration({
  db: DynamoDBDocumentClient.from(new DynamoDBClient({})),
  tableName,
});
