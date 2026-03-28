# Exercise 7: MCP Servers - External Integrations

## Goal
Learn how Model Context Protocol (MCP) connects Claude to external tools and services.

## Concepts

### What is MCP?
A protocol that gives Claude access to external tools: GitHub, databases, APIs, etc.
MCP servers run as background processes that Claude communicates with.

### Configuration
File: `.mcp.json` (project root)

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
| User | `~/.claude/.mcp.json` | No |
| Local | `.claude/.mcp.local.json` | No |

## Tasks

### 7.1 - Inspect the MCP Config
```bash
cat .mcp.json
```
This project has the GitHub MCP server configured. When a `GITHUB_TOKEN` is set,
Claude can interact with GitHub directly.

### 7.2 - Use the GitHub MCP Server
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

### 7.4 - Add a New MCP Server (Demo)
To add a filesystem MCP server, you would edit `.mcp.json`:
```json
{
  "mcpServers": {
    "github": { "..." : "..." },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp/shared"]
    }
  }
}
```

Popular MCP servers:
- `@anthropic-ai/github-mcp` - GitHub (issues, PRs, code search)
- `@modelcontextprotocol/server-filesystem` - File access outside project
- `@modelcontextprotocol/server-postgres` - PostgreSQL queries
- `@modelcontextprotocol/server-slack` - Slack messaging

## Key Takeaways
- MCP extends Claude with external tool access
- Servers run as background processes via stdio
- Use `.mcp.json` for shared config, `.mcp.local.json` for secrets
- Environment variables in MCP config can reference `${VAR}` syntax
- Many pre-built servers exist for popular services
