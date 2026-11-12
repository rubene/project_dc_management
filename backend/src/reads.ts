import { GetCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";
import type { Deps } from "./app.js";
import { queryByPrefix, type Prefix } from "./keys.js";

// Reads of the base table that see every write made before them, as access
// checks and anything decided from them need (docs/data-model.md).

export async function consistentGet({ db, tableName }: Deps, key: Record<string, string>) {
  const { Item } = await db.send(new GetCommand({ TableName: tableName, Key: key, ConsistentRead: true }));
  return Item;
}

// Every item under a prefix. A Query returns at most 1 MB at a time, so this
// reads every page.
export async function queryAll({ db, tableName }: Deps, prefix: Prefix) {
  const items = [];
  let startKey: Record<string, unknown> | undefined;
  do {
    const page = await db.send(new QueryCommand({
      TableName: tableName,
      ...queryByPrefix(prefix),
      ConsistentRead: true,
      ExclusiveStartKey: startKey,
    }));
    items.push(...(page.Items ?? []));
    startKey = page.LastEvaluatedKey;
  } while (startKey);
  return items;
}
