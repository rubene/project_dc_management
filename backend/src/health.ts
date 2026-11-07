import { GetCommand } from "@aws-sdk/lib-dynamodb";
import type { Deps } from "./app.js";
import { json } from "./http.js";
import { mainTableKeys } from "./mainTable.js";

// Well under the API Lambda's 10-second timeout, so a stalled database gets
// the documented 503 rather than the Lambda being cut off (a 502).
const databaseDeadlineMs = 3_000;

export async function getHealth({ clock, db, tableName }: Deps) {
  try {
    // A real read on the main table, so a missing table or a missing IAM
    // permission shows up here rather than in the first real request.
    await db.send(new GetCommand({
      TableName: tableName,
      Key: { [mainTableKeys.partitionKey]: "HEALTH", [mainTableKeys.sortKey]: "HEALTH" },
    }), { abortSignal: AbortSignal.timeout(databaseDeadlineMs) });
  } catch (error) {
    console.error("Health check couldn't read the main table", { tableName, error });
    return json(503, { status: "unavailable", database: "unavailable" });
  }
  return json(200, { status: "ok", database: "ok", time: clock.now().toISOString() });
}
