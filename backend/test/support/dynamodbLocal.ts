import { execFileSync } from "node:child_process";
import {
  CreateTableCommand,
  DynamoDBClient,
  ListTablesCommand,
} from "@aws-sdk/client-dynamodb";
import type { TestProject } from "vitest/node";
import { mainTableKeys } from "../../src/mainTable.js";

const image = "amazon/dynamodb-local:3.3.2";
const tableName = "dc-test-main";

declare module "vitest" {
  export interface ProvidedContext {
    dynamoEndpoint: string;
    tableName: string;
  }
}

// Starts DynamoDB Local in Docker once per test run and creates the main table.
export default async function setup(project: TestProject) {
  const containerId = execFileSync("docker", [
    "run", "-d", "--rm", "-p", "127.0.0.1::8000", image,
    "-jar", "DynamoDBLocal.jar", "-inMemory", "-sharedDb",
  ]).toString().trim();

  const stop = () => {
    execFileSync("docker", ["stop", containerId], { stdio: "ignore" });
  };

  try {
    const port = execFileSync("docker", ["port", containerId, "8000/tcp"])
      .toString().trim().split(":").pop();
    const endpoint = `http://127.0.0.1:${port}`;
    const client = localClient(endpoint);

    await waitUntilReady(client);
    await client.send(new CreateTableCommand({
      TableName: tableName,
      BillingMode: "PAY_PER_REQUEST",
      AttributeDefinitions: [
        { AttributeName: mainTableKeys.partitionKey, AttributeType: "S" },
        { AttributeName: mainTableKeys.sortKey, AttributeType: "S" },
      ],
      KeySchema: [
        { AttributeName: mainTableKeys.partitionKey, KeyType: "HASH" },
        { AttributeName: mainTableKeys.sortKey, KeyType: "RANGE" },
      ],
    }));

    project.provide("dynamoEndpoint", endpoint);
    project.provide("tableName", tableName);
  } catch (error) {
    stop();
    throw error;
  }

  return stop;
}

export function localClient(endpoint: string) {
  return new DynamoDBClient({
    endpoint,
    region: "us-west-2",
    credentials: { accessKeyId: "local", secretAccessKey: "local" },
  });
}

async function waitUntilReady(client: DynamoDBClient) {
  for (let attempt = 0; attempt < 150; attempt++) {
    try {
      await client.send(new ListTablesCommand({}));
      return;
    } catch {
      await new Promise((resolve) => setTimeout(resolve, 200));
    }
  }
  throw new Error("DynamoDB Local did not start");
}
