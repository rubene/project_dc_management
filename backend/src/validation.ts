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

// The IANA timezone's official spelling, such as America/Vancouver for
// "america/vancouver", or undefined if it isn't one. Intl knows every IANA
// name, aliases included. It also takes UTC offsets such as "+05:00", which
// aren't IANA names and don't follow daylight saving.
export function ianaTimezone(timezone: unknown): string | undefined {
  if (typeof timezone !== "string" || !/^[A-Za-z]/.test(timezone)) return undefined;
  try {
    return new Intl.DateTimeFormat("en-US", { timeZone: timezone }).resolvedOptions().timeZone;
  } catch {
    return undefined;
  }
}

// A parsed request body, or what's wrong with it.
export type Parsed<T> = { value: T } | { problem: string };
