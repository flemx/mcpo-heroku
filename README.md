# ⚡️ mcpo

Expose any MCP tool as an OpenAPI-compatible HTTP server—instantly.

mcpo is a dead-simple proxy that takes an MCP server command and makes it accessible via standard RESTful OpenAPI, so your tools "just work" with LLM agents and apps expecting OpenAPI servers.

No custom protocol. No glue code. No hassle.

## 🤔 Why Use mcpo Instead of Native MCP?

MCP servers usually speak over raw stdio, which is:

- 🔓 Inherently insecure
- ❌ Incompatible with most tools
- 🧩 Missing standard features like docs, auth, error handling, etc.

mcpo solves all of that—without extra effort:

- ✅ Works instantly with OpenAPI tools, SDKs, and UIs
- 🛡 Adds security, stability, and scalability using trusted web standards
- 🧠 Auto-generates interactive docs for every tool, no config needed
- 🔌 Uses pure HTTP—no sockets, no glue code, no surprises

What feels like "one more step" is really fewer steps with better outcomes.

mcpo makes your AI tools usable, secure, and interoperable—right now, with zero hassle.

## 🚀 Quick Usage

We recommend using uv for lightning-fast startup and zero config.

```bash
uvx mcpo --port 8000 --api-key "top-secret" -- your_mcp_server_command
```

Or, if you're using Python:

```bash
pip install mcpo
mcpo --port 8000 --api-key "top-secret" -- your_mcp_server_command
```

To use an SSE-compatible MCP server, simply specify the server type and endpoint:

```bash
mcpo --port 8000 --api-key "top-secret" --server-type "sse" -- http://127.0.0.1:8001/sse
```

## Docker

You can run mcpo via Docker with the included Dockerfile:

```bash
# Build the Docker image
docker build -t my-mcpo .

# Run with a configuration file
docker run -p 8000:8000 \
  -v "$(pwd)/mcp.json:/app/mcp.json" \
  -v "$(pwd)/custom:/app/custom" \
  my-mcpo --api-key "top-secret" --config "/app/mcp.json"
```

For convenience, a startup script is included:

```bash
# Make the script executable
chmod +x start.sh

# Run with default settings
./start.sh

# Or with custom parameters
./start.sh --api-key "your-api-key" --config "your-config.json" --port 9000

# Force a rebuild of the Docker image
./start.sh --build
```

By default, the script will:
- Build the image only if it doesn't exist yet
- Use the existing image if available
- Rebuild only when the `--build` flag is specified

Example:

```bash
uvx mcpo --port 8000 --api-key "top-secret" -- uvx mcp-server-time --local-timezone=America/New_York
```

That's it. Your MCP tool is now available at http://localhost:8000 with a generated OpenAPI schema — test it live at [http://localhost:8000/docs](http://localhost:8000/docs).

🤝 **To integrate with Open WebUI after launching the server, check our [docs](https://docs.openwebui.com/openapi-servers/open-webui/).**

### 🔄 Using a Config File

You can serve multiple MCP tools via a single config file that follows the [Claude Desktop](https://modelcontextprotocol.io/quickstart/user) format:

Start via:

```bash
mcpo --config /path/to/config.json
```

Example config.json:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "time": {
      "command": "uvx",
      "args": ["mcp-server-time", "--local-timezone=America/New_York"]
    },
    "mcp_sse": {
      "url": "http://127.0.0.1:8001/sse"
    } // SSE MCP Server
  }
}
```

Each tool will be accessible under its own unique route, e.g.:
- http://localhost:8000/memory
- http://localhost:8000/time

Each with a dedicated OpenAPI schema and proxy handler. Access full schema UI at: `http://localhost:8000/<tool>/docs`  (e.g. /memory/docs, /time/docs)

## 🔧 Requirements

- Python 3.8+
- uv (optional, but highly recommended for performance + packaging)

## 🛠️ Development & Testing

To contribute or run tests locally:

1.  **Set up the environment:**
    ```bash
    # Clone the repository
    git clone https://github.com/open-webui/mcpo.git
    cd mcpo

    # Install dependencies (including dev dependencies)
    uv sync --dev
    ```

2.  **Run tests:**
    ```bash
    uv run pytest
    ```





## Heroku Deployment

You can deploy mcpo directly to Heroku using the included `heroku.yml` file:

```bash
# Login to Heroku
heroku login

# Create a new Heroku app (or use an existing one)
heroku create your-app-name

# Set the stack to container
heroku stack:set container -a app-name

# Set required environment variables
heroku config:set API_KEY=your-secret-api-key

# Push to Heroku
git push heroku main
```

The deployment automatically:
- Builds the Docker image using the Dockerfile
- Uses your API_KEY environment variable for authentication
- Uses Heroku's dynamic PORT assignment
- Runs with the mcp.json config file

To check your logs after deployment:
```bash
heroku logs --tail
```

Your MCProxy API will be available at `https://your-app-name.herokuapp.com/`

## Environment Variables

mcpo now supports loading environment variables from a `.env` file. This is useful for keeping sensitive information like API keys out of your codebase.

1. Create a `.env` file in your project root:
```
# API Keys
OPENAI_API_KEY=your_openai_api_key_here

# Salesforce Credentials
SALESFORCE_USERNAME=your_salesforce_username
SALESFORCE_PASSWORD=your_salesforce_password

# MCPO Settings
API_KEY=top-secret
```

2. Update your `mcp.json` to use environment variables:
```json
"env": {
  "OPENAI_API_KEY": "${OPENAI_API_KEY}",
}
```

3. For Heroku, set these same variables using:
```bash
heroku config:set OPENAI_API_KEY=your_key
# etc.
```



## 🪪 License

MIT