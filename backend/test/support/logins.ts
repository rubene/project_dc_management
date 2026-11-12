import { randomUUID } from "node:crypto";
import type { Login } from "../../src/auth.js";
import type { TestApi } from "./api.js";

export type { Login } from "../../src/auth.js";

// A Cognito login nobody has used yet.
export function newLogin(): Login {
  const sub = randomUUID();
  return { sub, email: `${sub}@example.test`, emailVerified: true };
}

// A login whose person has signed up, as their token's claims look afterwards.
export async function signedUp(api: TestApi, name = "Ana Owner"): Promise<Login> {
  const login = newLogin();
  const response = await api.as(login).put("/me", { name });
  const { personId } = response.body as { personId: string };
  return { ...login, personId };
}
