import { randomBytes } from "node:crypto";
import {
  AdminCreateUserCommand,
  AdminDeleteUserCommand,
  AdminSetUserPasswordCommand,
  CognitoIdentityProviderClient,
} from "@aws-sdk/client-cognito-identity-provider";
import { test as base } from "@playwright/test";
import { stage, stageOutput } from "./stage.js";

// Logins made straight in the stage's user pool, with their emails already
// verified, since a test can't read the code Cognito emails. Creating an
// account through the app is left to the widget tests.

export type Login = { email: string; password: string };

const cognito = new CognitoIdentityProviderClient({
  region: "us-west-2",
  profile: process.env.AWS_PROFILE ?? "project_dc",
});

async function createLogin(name: string): Promise<Login> {
  if (stage === "prod") throw new Error("The browser tests make throwaway logins, so they don't run against prod.");
  const email = `e2e-${randomBytes(6).toString("hex")}-${name}@example.test`;
  const password = `E2e-${randomBytes(12).toString("base64url")}1!`;
  const UserPoolId = stageOutput("UserPoolId");
  await cognito.send(new AdminCreateUserCommand({
    UserPoolId,
    Username: email,
    MessageAction: "SUPPRESS",
    UserAttributes: [{ Name: "email", Value: email }, { Name: "email_verified", Value: "true" }],
  }));
  await cognito.send(new AdminSetUserPasswordCommand({ UserPoolId, Username: email, Password: password, Permanent: true }));
  return { email, password };
}

// `logins.make("ari")` gives a fresh login, deleted once the test ends. What
// it did in the app stays in the stage's table, under a unique email.
export const test = base.extend<{ logins: { make(name: string): Promise<Login> } }>({
  logins: async ({}, use) => {
    const made: Login[] = [];
    await use({
      make: async (name) => {
        const login = await createLogin(name);
        made.push(login);
        return login;
      },
    });
    await Promise.all(made.map(({ email }) =>
      cognito.send(new AdminDeleteUserCommand({ UserPoolId: stageOutput("UserPoolId"), Username: email }))));
  },
});

export { expect } from "@playwright/test";
