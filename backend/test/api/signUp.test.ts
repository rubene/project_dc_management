import { describe, expect, test } from "vitest";
import { testApi } from "../support/api.js";
import { newLogin } from "../support/logins.js";

describe("PUT /me", () => {
  test("a request without a login is refused", async () => {
    const response = await testApi().put("/me", { name: "Ana Owner" });

    expect(response.status).toBe(401);
  });

  test("a new login signs up and can then see who they are", async () => {
    const login = newLogin();

    const signUp = await testApi().as(login).put("/me", { name: "Ana Owner" });
    expect(signUp.status).toBe(201);
    const { personId } = signUp.body as { personId: string };

    const me = await testApi().as({ ...login, personId }).get("/me");
    expect(me.status).toBe(200);
    expect(me.body).toMatchObject({ personId, name: "Ana Owner", email: login.email });
  });

  // The app retries sign-up if it loses the response, so a login must never
  // end up with two people.
  test("signing up again with the same login returns the same person", async () => {
    const login = newLogin();
    const first = await testApi().as(login).put("/me", { name: "Ana Owner" });

    const second = await testApi().as(login).put("/me", { name: "Ana Owner" });

    expect(second.status).toBe(201);
    expect(second.body).toEqual(first.body);
  });

  test("signing up needs a name", async () => {
    const response = await testApi().as(newLogin()).put("/me", { name: " " });

    expect(response.status).toBe(400);
  });

  test("signing up with a field the API doesn't know is refused", async () => {
    const response = await testApi().as(newLogin()).put("/me", { name: "Ana Owner", role: "Owner" });

    expect(response.status).toBe(400);
  });
});

describe("GET /me", () => {
  // The login is valid, so this isn't "sign in first".
  test("a token naming a person who doesn't exist is refused", async () => {
    const response = await testApi().as({ ...newLogin(), personId: "01KNOSUCHPERSON0000000000" }).get("/me");

    expect(response.status).toBe(403);
  });
});
