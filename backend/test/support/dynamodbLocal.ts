import { execFileSync } from "node:child_process";
import {
  CreateTableCommand,
  DynamoDBClient,
  ResourceInUseException,
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
    const endpoint = `http://127.0.0.1:${await hostPort(containerId)}`;
    const client = localClient(endpoint);

    await createMainTable(client);

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

// Right after `docker run -d`, `docker port` can print nothing yet, so wait
// until it reports the host port Docker picked.
async function hostPort(containerId: string) {
  for (let attempt = 0; attempt < 50; attempt++) {
    const output = execFileSync("docker", ["port", containerId, "8000/tcp"]).toString();
    const port = output.match(/:(\d+)\s*$/m)?.[1];
    if (port) return port;
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  throw new Error("Docker didn't report a host port for DynamoDB Local");
}

// DynamoDB Local can accept connections, and even answer some requests,
// before it can create tables, so creating the table is the readiness check.
// A table already there means an earlier attempt worked.
async function createMainTable(client: DynamoDBClient) {
  let lastError: unknown;
  for (let attempt = 0; attempt < 150; attempt++) {
    try {
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
      return;
    } catch (error) {
      if (error instanceof ResourceInUseException) return;
      lastError = error;
      await new Promise((resolve) => setTimeout(resolve, 200));
    }
  }
  throw new Error("DynamoDB Local didn't become ready within 30 seconds", { cause: lastError });
}
