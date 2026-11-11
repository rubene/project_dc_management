import { readFileSync } from "node:fs";
import { Ajv2020 } from "ajv/dist/2020.js";
import addFormats from "ajv-formats";
import { parse } from "yaml";

// The OpenAPI definition is the contract with the apps, so every documented
// response a test receives must match it.
const definitionPath = new URL("../../../api/openapi.yaml", import.meta.url);

type Response = { $ref?: string; content?: Record<string, { schema: object }> };

type Definition = {
  paths: Record<string, Record<string, {
    responses: Record<string, Response>;
  }>>;
  components?: { schemas?: Record<string, object>; responses?: Record<string, Response> };
};

const definition = parse(readFileSync(definitionPath, "utf8")) as Definition;

const ajv = new Ajv2020({ strict: false, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(
  { $id: "openapi", components: definition.components ?? {} },
);

// Paths the definition doesn't describe must return its Error response with
// a 404, so a route added without documenting it fails the tests.
export function assertMatchesDefinition(
  method: string, path: string, status: number, body: unknown,
) {
  const operation = definition.paths[documentedPath(path)]?.[method.toLowerCase()];
  if (!operation) {
    if (status !== 404) {
      throw new Error(`${method} ${path} returned ${status}, but it isn't in the OpenAPI definition`);
    }
    return assertMatchesSchema(`${method} ${path} ${status}`, { $ref: "#/components/schemas/Error" }, body);
  }

  const response = resolveResponse(operation.responses[String(status)]);
  if (!response) {
    throw new Error(`${method} ${path} returned ${status}, which the OpenAPI definition doesn't document`);
  }

  const schema = response.content?.["application/json"]?.schema;
  if (schema) assertMatchesSchema(`${method} ${path} ${status}`, schema, body);
}

// The definition's path for a concrete one, such as
// "/organizations/{orgId}/centers" for "/organizations/01J…/centers".
function documentedPath(path: string): string {
  if (definition.paths[path]) return path;
  const template = Object.keys(definition.paths).find((candidate) =>
    new RegExp(`^${candidate.replace(/\{\w+\}/g, "[^/]+")}$`).test(path));
  return template ?? path;
}

// Shared responses are written as "#/components/responses/X" refs.
function resolveResponse(response: Response | undefined): Response | undefined {
  const name = response?.$ref?.match(/^#\/components\/responses\/(.+)$/)?.[1];
  if (!name) return response;
  const shared = definition.components?.responses?.[name];
  if (!shared) throw new Error(`The OpenAPI definition has no shared response ${name}`);
  return shared;
}

function assertMatchesSchema(label: string, schema: object, body: unknown) {
  const validate = ajv.compile(rewriteRefs(schema));
  if (!validate(body)) {
    throw new Error(
      `${label} doesn't match the OpenAPI definition: ` +
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
