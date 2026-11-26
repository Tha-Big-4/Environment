# Postman

- `<project>.postman_collection.json`: hand-made requests with examples and sign-in flows that a
  generated collection does not have.
- `local.postman_environment.json`: variables such as `baseUrl`. **No secrets**; set tokens and
  passwords as Postman "current values", which are not exported.

For every endpoint at once, import the OpenAPI file from `../openapi/` instead (Import → File).
The Postman MCP server (backend `.mcp.json`) can create and run collections from the agent.
