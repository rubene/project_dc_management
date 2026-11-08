import type { Clock } from "../../src/clock.js";

// A clock that always says the same time, so time-based rules can be tested
// against known moments.
export function fixedClock(isoTime: string): Clock {
  const time = new Date(isoTime);
  return { now: () => new Date(time) };
}
