// Who saved a record, when, and through what (docs/data-model.md, "Records
// are ready for offline use"). Every request comes from an app until the
// Assistant arrives. `deviceId` is added once devices are registered (#14).
export function recordedBy(personId: string, now: Date) {
  return { recordedAt: now.toISOString(), recordedBy: personId, recordedVia: "app" as const };
}
