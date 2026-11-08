import { expect, test } from "vitest";
import { testApi } from "../support/api.js";

test("a path the API doesn't have returns 404", async () => {
  const response = await testApi().get("/no-such-path");

  expect(response.status).toBe(404);
});
