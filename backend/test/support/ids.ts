import { ulid } from "ulid";
import type { Clock } from "../../src/clock.js";

// An ID as an app creates it on the device: a ULID made at the clock's time.
export function deviceId(clock: Clock) {
  return ulid(clock.now().getTime());
}
