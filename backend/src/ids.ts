import { decodeTime, isValid } from "ulid";

// Records created in the apps take their ID from the device, as a ULID
// (docs/data-model.md, "Records are ready for offline use"). A ULID's time
// must be within 7 days of the server's clock, so a device with a wrong
// clock can't put a record outside retention.
const allowedClockSkewMs = 7 * 24 * 60 * 60 * 1000;

export function isDeviceId(id: unknown, now: Date): id is string {
  if (typeof id !== "string" || !isValid(id)) return false;
  return Math.abs(decodeTime(id) - now.getTime()) <= allowedClockSkewMs;
}

export const deviceIdProblem = "IDs must be ULIDs created by the app within 7 days of the server's time";
