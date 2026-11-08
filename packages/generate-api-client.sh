#!/usr/bin/env bash
# Regenerates packages/api_client from api/openapi.yaml. Run it after every
# change to the OpenAPI definition and commit the result. Needs Docker.
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
rm -rf "$repo/packages/api_client"
docker run --rm -u "$(id -u):$(id -g)" -v "$repo:/repo" \
  openapitools/openapi-generator-cli:v7.17.0 generate \
  -i /repo/api/openapi.yaml \
  -g dart \
  -o /repo/packages/api_client \
  --additional-properties=pubName=dc_api_client,pubDescription="DC Management API client, generated from api/openapi.yaml",pubAuthor=,pubHomepage= \
  --global-property=apiTests=false,modelTests=false,apiDocs=true,modelDocs=true
rm -rf "$repo/packages/api_client/.openapi-generator" "$repo/packages/api_client/git_push.sh" "$repo/packages/api_client/.travis.yml" "$repo/packages/api_client/test"
