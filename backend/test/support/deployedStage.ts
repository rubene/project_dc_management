import { readFileSync } from "node:fs";
import { parseStage, stackName, type Stage } from "../../infra/stage.js";

// The deployed stage under test, and its stack outputs. Each output comes from
// an environment variable if set, otherwise from the cdk-outputs file the last
// deploy from this machine wrote. A fresh checkout or a CI job checking an
// existing deployment passes the environment variables instead.
export const stage = parseStage(process.env.STAGE ?? "dev");

type OutputName = "ApiUrl" | "AdminWebUrl" | "AdminWebBucketUrl";

const envVars: Record<OutputName, string> = {
  ApiUrl: "API_URL",
  AdminWebUrl: "ADMIN_WEB_URL",
  AdminWebBucketUrl: "ADMIN_WEB_BUCKET_URL",
};

// Always ends with a slash, so a relative URL adds to the last path segment
// (such as the API's "v1" stage) instead of replacing it.
export function stageUrl(name: OutputName) {
  const url = process.env[envVars[name]] ?? fromCdkOutputs(stage, name);
  return url.endsWith("/") ? url : `${url}/`;
}

function fromCdkOutputs(stage: Stage, name: OutputName) {
  const file = `cdk-outputs.${stage}.json`;
  let outputs: Record<string, Partial<Record<OutputName, string>>>;
  try {
    outputs = JSON.parse(readFileSync(new URL(`../../${file}`, import.meta.url), "utf8"));
  } catch (error) {
    throw new Error(`Can't read ${file}. Deploy first, or set ${envVars[name]}.`, { cause: error });
  }
  const url = outputs[stackName(stage)]?.[name];
  if (!url) throw new Error(`No ${name} for stage "${stage}" in ${file}. Deploy again, or set ${envVars[name]}.`);
  return url;
}
