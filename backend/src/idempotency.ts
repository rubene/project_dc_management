import { createHash } from "node:crypto";
import { TransactionCanceledException } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";
import { TransactWriteCommand, type DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import { itemExists, itemIsNew } from "./keys.js";

// Creates are conditional puts that keep a hash of the request, so a retry
// gets the original result back and a different request with the same ID is
// a conflict (docs/data-model.md, "Duplicate-safe retries").

export function requestHash(personId: string, request: unknown): string {
  return createHash("sha256").update(JSON.stringify([personId, request])).digest("base64url");
}

type Item = Record<string, unknown>;

// A transaction put that creates an item, and fails if it's already there.
// `returnExisting` asks for the existing item back when it fails.
export function createOnly(tableName: string, item: Item, { returnExisting = false } = {}) {
  return {
    Put: {
      TableName: tableName,
      Item: item,
      ...itemIsNew,
      ...(returnExisting && { ReturnValuesOnConditionCheckFailure: "ALL_OLD" as const }),
    },
  };
}

// A transaction check that an item is there, such as the Owner record that
// allows a write.
export function mustExist(tableName: string, key: Item) {
  return { ConditionCheck: { TableName: tableName, Key: key, ...itemExists } };
}

type Write = ReturnType<typeof createOnly> | ReturnType<typeof mustExist>;

export type CreateOutcome =
  | { outcome: "created" }
  // The same request was already saved; `original` is its first item.
  | { outcome: "repeated"; original: Item }
  // Something with the same ID was created by a different request.
  | { outcome: "conflict" }
  // A `mustExist` check failed.
  | { outcome: "refused" };

// Writes a create transaction. Its first write is a `createOnly` with
// `returnExisting`, and `isSameRequest` tells from that item whether the
// earlier write came from this same request.
export async function createOnce(
  db: DynamoDBDocumentClient,
  writes: Write[],
  isSameRequest: (original: Item) => boolean,
): Promise<CreateOutcome> {
  for (let attempt = 1; ; attempt++) {
    try {
      await db.send(new TransactWriteCommand({ TransactItems: writes }));
      return { outcome: "created" };
    } catch (error) {
      if (!(error instanceof TransactionCanceledException)) throw error;
      const reasons = error.CancellationReasons ?? [];
      // Another transaction on the same items was in progress, such as a
      // retry of this request arriving at the same moment. Trying again
      // finds what it wrote.
      if (reasons.some((reason) => reason.Code === "TransactionConflict") && attempt === 1) continue;

      const failed = (index: number) => reasons[index]?.Code === "ConditionalCheckFailed";
      const first = reasons[0];
      if (failed(0) && first?.Item) {
        const original = unmarshall(first.Item);
        if (isSameRequest(original)) return { outcome: "repeated", original };
      }
      if (writes.some((write, index) => "ConditionCheck" in write && failed(index))) return { outcome: "refused" };
      if (reasons.some((_, index) => failed(index))) return { outcome: "conflict" };
      throw error;
    }
  }
}
