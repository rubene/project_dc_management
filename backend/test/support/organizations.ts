import type { TestApi } from "./api.js";
import { deviceId } from "./ids.js";
import { signedUp, type Login } from "./logins.js";
import type { Clock } from "../../src/clock.js";

// An Owner who has created their Organization, with its first Center in
// Vancouver, billing in CAD.
export async function ownerWithOrganization(
  api: TestApi, clock: Clock,
): Promise<{ owner: Login; orgId: string; firstCenterId: string }> {
  const owner = await signedUp(api);
  const orgId = deviceId(clock);
  const firstCenterId = deviceId(clock);
  await api.as(owner).post("/organizations", {
    id: orgId,
    name: "Little Oaks",
    center: { id: firstCenterId, name: "Little Oaks Downtown", currency: "CAD", timezone: "America/Vancouver" },
  });
  return { owner, orgId, firstCenterId };
}
