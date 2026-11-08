import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { createApp } from "./app.js";
import { systemClock } from "./clock.js";

const tableName = process.env.TABLE_NAME;
if (!tableName) throw new Error("TABLE_NAME is not set");

export const handler = createApp({
  clock: systemClock,
  db: DynamoDBDocumentClient.from(new DynamoDBClient({})),
  tableName,
});
