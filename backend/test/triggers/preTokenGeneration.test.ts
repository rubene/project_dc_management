import { describe, expect, test } from "vitest";
import { testApi } from "../support/api.js";
import { claimsAddedFor } from "../support/cognito.js";
import { newLogin } from "../support/logins.js";

describe("pre-token generation", () => {
  // The app signs up with PUT /me first, then refreshes the tokens.
  test("a login that hasn't signed up gets no person ID in its tokens", async () => {
    const claims = await claimsAddedFor(newLogin());

    expect(claims.idToken).not.toHaveProperty("personId");
    expect(claims.accessToken).not.toHaveProperty("personId");
  });

  test("after signing up, the tokens carry the person ID the API expects", async () => {
    const login = newLogin();
    const signUp = await testApi().as(login).put("/me", { name: "Ana Owner" });
    const { personId } = signUp.body as { personId: string };

    const claims = await claimsAddedFor(login);

    expect(claims.idToken).toMatchObject({ personId });
    expect(claims.accessToken).toMatchObject({ personId });
    const me = await testApi().as({ ...login, ...claims.idToken }).get("/me");
    expect(me.status).toBe(200);
  });
});
