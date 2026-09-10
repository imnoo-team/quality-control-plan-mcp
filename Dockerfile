# Runs the published quality-control-plan-mcp server over stdio.
# Used by Glama to verify the server starts and answers introspection.
FROM node:20-alpine

# The package is pure JS (pdf-lib, fontkit, xlsx-js-style), so no build tools needed.
RUN npm install -g quality-control-plan-mcp@0.1.0

# stdio transport: the client speaks JSON-RPC over stdin/stdout.
ENTRYPOINT ["quality-control-plan-mcp"]
