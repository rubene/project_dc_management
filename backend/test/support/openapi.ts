import { readFileSync } from "node:fs";
import { Ajv2020 } from "ajv/dist/2020.js";
import addFormats from "ajv-formats";
import { parse } from "yaml";

// The OpenAPI definition is the contract with the apps, so every documented
// response a test receives must match it.
const definitionPath = new URL("../../../api/openapi.yaml", import.meta.url);

type Definition = {
  paths: Record<string, Record<string, {
    responses: Record<string, { content?: Record<string, { schema: object }> }>;
  }>>;
  components?: { schemas?: Record<string, object> };
};

const definition = parse(readFileSync(definitionPath, "utf8")) as Definition;

const ajv = new Ajv2020({ strict: false, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(
  { $id: "openapi", components: definition.components ?? {} },
);

export function isDocumented(method: string, path: string) {
  return Boolean(definition.paths[path]?.[method.toLowerCase()]);
}

export function assertMatchesDefinition(
  method: string, path: string, status: number, body: unknown,
) {
  const operation = definition.paths[path]?.[method.toLowerCase()];
  if (!operation) throw new Error(`${method} ${path} is not in the OpenAPI definition`);

  const response = operation.responses[String(status)];
  if (!response) {
    throw new Error(`${method} ${path} returned ${status}, which the OpenAPI definition doesn't document`);
  }

  const schema = response.content?.["application/json"]?.schema;
  if (!schema) return;

  const validate = ajv.compile(rewriteRefs(schema));
  if (!validate(body)) {
    throw new Error(
      `${method} ${path} ${status} doesn't match the OpenAPI definition: ` +
      ajv.errorsText(validate.errors) + `\nBody: ${JSON.stringify(body)}`,
    );
  }
}

// "#/components/schemas/X" refs point inside the definition; resolve them
// against the schema registered above.
function rewriteRefs(schema: object): object {
  return JSON.parse(
    JSON.stringify(schema).replaceAll('"$ref":"#/', '"$ref":"openapi#/'),
  );
}
