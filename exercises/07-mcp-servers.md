# Exercise 7: MCP Servers - External Integrations

> **Note:** MCP servers that access external services (GitHub, npm, databases) require
> network access beyond what a sandboxed environment allows. If your organization uses
> sandbox mode, this exercise is a **conceptual walkthrough** — follow along with the
> presenter's demo rather than running commands yourself.

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
| User / Local | `~/.claude.json` | No |

## Tasks

### 7.1 - Inspect the MCP Config
```bash
cat .mcp.json
```
This project has the GitHub MCP server configured. When a `GITHUB_TOKEN` is set,
Claude can interact with GitHub directly.

> **Security reminder:** If you use a GitHub token, use a fine-grained personal access
> token with minimal scopes (read-only). Never use production tokens or tokens with
> write access to sensitive repositories. Tokens are passed to the MCP server process
> which communicates with Claude.

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

### 7.4 - Other MCP Servers (Reference)
MCP servers exist for many services. Adding them follows the same `.mcp.json` pattern:

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

> These all require network access to their respective services.
> Check with your organization's policies before configuring external MCP servers.

## Key Takeaways
- MCP extends Claude with external tool access
- Servers run as background processes via stdio
- Use `.mcp.json` for shared config, `~/.claude.json` for personal servers
- Environment variables in MCP config can reference `${VAR}` syntax
- Many pre-built servers exist for popular services
- External MCP servers require network access — check your sandbox/policy settings
