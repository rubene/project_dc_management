import { createHash } from "node:crypto";
import { TransactionCanceledException } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";
import { TransactWriteCommand, type DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";
import type { mustHoldRole } from "./centerPeople.js";
import { itemExists, itemIsNew } from "./keys.js";

// Creates and changes are conditional transactions whose first item keeps a
// hash of the request: a new record, or the history item of a changed one.
// A retry gets the original result back from that item, and a different
// request that collides with it is a conflict (docs/data-model.md,
// "Duplicate-safe retries").

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

// A transaction put that replaces a head, and fails unless the head is still
// at the version the change expects, so two changes can't both win.
export function replaceIfVersion(tableName: string, item: Item, expectedVersion: number) {
  return {
    Put: {
      TableName: tableName,
      Item: item,
      ConditionExpression: "#version = :expected",
      ExpressionAttributeNames: { "#version": "version" },
      ExpressionAttributeValues: { ":expected": expectedVersion },
    },
  };
}

type Write =
  | ReturnType<typeof createOnly>
  | ReturnType<typeof mustExist>
  | ReturnType<typeof mustHoldRole>
  | ReturnType<typeof replaceIfVersion>;

export type WriteOutcome =
  | { outcome: "written" }
  // The same request was already saved; `original` is its first item.
  | { outcome: "repeated"; original: Item }
  // A different request got there first: an item with the same ID already
  // exists, or the head has moved past the version a change expected.
  | { outcome: "conflict" }
  // A `mustExist` or `mustHoldRole` check failed.
  | { outcome: "refused" };

// Writes a create or change transaction once. Its first write is a
// `createOnly` with `returnExisting`, and `isSameRequest` tells from that item
// whether the earlier write came from this same request.
export async function writeOnce(
  db: DynamoDBDocumentClient,
  writes: Write[],
  isSameRequest: (original: Item) => boolean,
): Promise<WriteOutcome> {
  for (let attempt = 1; ; attempt++) {
    try {
      await db.send(new TransactWriteCommand({ TransactItems: writes }));
      return { outcome: "written" };
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
