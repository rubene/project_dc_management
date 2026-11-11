// Checks on request bodies. The OpenAPI definition documents the same rules.

// A person's, Organization's or Center's name: 1 to 200 characters once
// surrounding spaces are removed.
export function cleanName(value: unknown): string | undefined {
  if (typeof value !== "string") return undefined;
  const name = value.trim();
  return name.length >= 1 && name.length <= 200 ? name : undefined;
}

export function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

// The first field of `body` that isn't in `allowed`. The OpenAPI schemas say
// `additionalProperties: false`, so a request can't carry fields the API
// would silently drop.
export function unknownField(body: Record<string, unknown>, allowed: readonly string[]): string | undefined {
  return Object.keys(body).find((field) => !allowed.includes(field));
}
