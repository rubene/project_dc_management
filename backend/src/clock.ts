// Business rules read the time from here, never from `new Date()`, so tests
// can control it.
export type Clock = { now(): Date };

export const systemClock: Clock = { now: () => new Date() };
