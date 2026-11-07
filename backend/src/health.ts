import { GetCommand } from "@aws-sdk/lib-dynamodb";
import type { Deps } from "./app.js";
import { json } from "./http.js";
import { mainTableKeys } from "./mainTable.js";

export async function getHealth({ clock, db, tableName }: Deps) {
  try {
    // A real read on the main table, so a missing table or a missing IAM
    // permission shows up here rather than in the first real request.
    await db.send(new GetCommand({
      TableName: tableName,
      Key: { [mainTableKeys.partitionKey]: "HEALTH", [mainTableKeys.sortKey]: "HEALTH" },
    }));
  } catch (error) {
    console.error("Health check couldn't read the main table", { tableName, error });
    return json(503, { status: "unavailable", database: "unavailable" });
  }
  return json(200, { status: "ok", database: "ok", time: clock.now().toISOString() });
}
