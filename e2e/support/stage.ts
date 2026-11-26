import { readFileSync } from "node:fs";

// The deployed stage under test, and its stack outputs. Each comes from an
// environment variable if set, otherwise from the cdk-outputs file the last
// deploy from this machine wrote (as in backend/test/support/deployedStage.ts).
export const stage = process.env.STAGE ?? "dev";

type OutputName = "AdminWebUrl" | "UserPoolId";
const envVars: Record<OutputName, string> = { AdminWebUrl: "ADMIN_WEB_URL", UserPoolId: "USER_POOL_ID" };

export function stageOutput(name: OutputName): string {
  const fromEnv = process.env[envVars[name]];
  if (fromEnv) return fromEnv;
  const file = new URL(`../../backend/cdk-outputs.${stage}.json`, import.meta.url);
  let outputs: Record<string, Partial<Record<OutputName, string>>>;
  try {
    outputs = JSON.parse(readFileSync(file, "utf8"));
  } catch (error) {
    throw new Error(`Can't read ${file.pathname}. Deploy ${stage} first, or set ${envVars[name]}.`, { cause: error });
  }
  const value = outputs[`dc-${stage}`]?.[name];
  if (!value) throw new Error(`No ${name} for stage "${stage}". Deploy again, or set ${envVars[name]}.`);
  return value;
}

export const adminWebUrl = () => stageOutput("AdminWebUrl");
