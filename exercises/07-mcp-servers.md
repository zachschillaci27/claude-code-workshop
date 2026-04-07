# Exercise 7: MCP Servers - External Integrations

> **Note:** MCP servers that access external services (GitHub, npm, databases) require
> network access beyond what a sandboxed environment allows. If your organization uses
> sandbox mode, this exercise is a **conceptual walkthrough** — follow along with the
> presenter's demo rather than running commands yourself.
>
> **Network sandbox:** The enterprise sandbox restricts outbound connections to
> `*.anthropic.com` and `*.claude.ai` only. The GitHub MCP server (`api.githubcopilot.com`)
> will be blocked unless you extend your personal allowlist in `~/.claude/settings.json`:
> ```json
> {
>   "sandbox": {
>     "network": {
>       "allowedDomains": [
>         "*.anthropic.com",
>         "*.claude.ai",
>         "api.githubcopilot.com"
>       ]
>     }
>   }
> }
> ```

## Goal
Learn how Model Context Protocol (MCP) connects Claude to external tools and services.

## Concepts

### What is MCP?
A protocol that gives Claude access to external tools: GitHub, databases, APIs, etc.
MCP servers run as background processes that Claude communicates with.

### Configuration
File: `.mcp.json` (project root)

MCP servers can use two transport types:

**HTTP transport** (remote servers with a URL endpoint):
```json
{
  "mcpServers": {
    "server-name": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_KEY}" }
    }
  }
}
```

**stdio transport** (local servers run as a subprocess):
```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@package/server-name"],
      "env": { "API_KEY": "${API_KEY}" }
    }
  }
}
```

### Scopes
| Scope | Path | Shared |
|-------|------|--------|
| Project | `.mcp.json` | Yes (git) |
| User / Local | `~/.claude/settings.json` | No |

## Tasks

### 7.1 - Inspect the MCP Config
```bash
cat .mcp.json
```
This project has the GitHub MCP server configured using the HTTP transport against
the GitHub Copilot MCP endpoint (`https://api.githubcopilot.com/mcp`).
The `Authorization` header references `${GITHUB_TOKEN}` — set this environment variable
before starting Claude Code to enable live GitHub integration:

```bash
export GITHUB_TOKEN=<your-fine-grained-pat>
```

> **Security reminder:** Use a fine-grained personal access token with minimal scopes
> (read-only). Never hardcode tokens in `.mcp.json` — use `${VAR}` references so the
> token stays out of version control. The token is sent in the `Authorization` header
> on every MCP request.

### 7.2 - Use the GitHub MCP Server (Demo)
With the GitHub MCP server active, Claude can:
```
"Create an issue titled 'Add pagination to task list endpoint'"
"List open pull requests"
"Search for TODO comments in the codebase on GitHub"
```

### 7.3 - Understand MCP Server Discovery
Ask Claude:
```
"What MCP tools do you have available?"
```
Claude will list all tools provided by connected MCP servers.

### 7.4 - MCP Tools and Context Usage

Every tool definition loaded from an MCP server consumes tokens in Claude's context window. This becomes significant at scale:

| Tools loaded | Approximate token cost |
|---|---|
| 5 tools | ~1–2K tokens |
| 20 tools | ~4–8K tokens |
| 50 tools | ~10–20K tokens |
| 100+ tools | context pressure, accuracy drops |

Tool selection accuracy also degrades once more than ~30–50 tools are loaded at once.

**Tool Search** solves this. Instead of injecting all tool definitions upfront, Claude receives a summary of available tools and searches for relevant ones on demand — loading only the 3–5 best matches per turn. Requires Claude Sonnet 4+ or Opus 4+ (not Haiku).

Behavior is controlled by the `ENABLE_TOOL_SEARCH` env var:

| Value | Behavior |
|---|---|
| *(unset)* or `true` | Always on — definitions never pre-loaded |
| `auto` | Activates when tool definitions exceed 10% of context window |
| `auto:5` | Same, with a custom threshold (5% here) |
| `false` | Off — all definitions loaded every turn |

Example with the Agent SDK (TypeScript):
```typescript
import { query } from "@anthropic-ai/sdk/agent";

for await (const message of query({
  prompt: "Find and run the appropriate database query",
  options: {
    mcpServers: {
      "enterprise-tools": {
        type: "http",
        url: "https://tools.example.com/mcp"
      }
    },
    allowedTools: ["mcp__enterprise-tools__*"],
    env: {
      ENABLE_TOOL_SEARCH: "auto:5"
    }
  }
})) { ... }
```

> **Rule of thumb:** fewer than ~10 tools → load everything (`false`). Large catalogs (50+) → use tool search. MCP servers with many tools benefit the most.

### 7.5 - Other MCP Servers (Reference)
MCP servers exist for many services. Adding them follows the same `.mcp.json` pattern:

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": { "Authorization": "Bearer ${GITHUB_TOKEN}" }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/Desktop",
        "/path/to/other/allowed/dir"
      ]
    }
  }
}
```

Popular MCP servers:
- GitHub Copilot MCP (`https://api.githubcopilot.com/mcp`) - GitHub issues, PRs, code search (HTTP)
- `@modelcontextprotocol/server-filesystem` - File access outside project (stdio)

> These all require network access to their respective services.
> Check with your organization's policies before configuring external MCP servers.

## Key Takeaways
- MCP extends Claude with external tool access
- Two transport types: `http` (remote URL + headers) and `stdio` (local subprocess)
- Use `.mcp.json` for shared config, `~/.claude/settings.json` for personal servers
- Header values and env vars in MCP config can reference `${VAR}` syntax
- Many pre-built servers exist for popular services
- External MCP servers require network access — check your sandbox/policy settings
- Tool definitions consume context tokens — 50 tools can cost 10–20K tokens
- Tool search (Claude Sonnet 4+) loads only the 3–5 relevant tools on demand, keeping context lean and tool selection accurate at scale
