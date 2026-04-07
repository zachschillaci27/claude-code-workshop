# Claude Code Cheat Sheet

Quick reference for everything covered in the workshop. Keep this handy.

---

## Launch & Sessions

```bash
claude                       # Start new session
claude --continue            # Resume last session
claude --resume              # Pick a session to resume
claude -p "prompt"           # One-shot (non-interactive)
claude --agent reviewer      # Start session with custom agent
claude --model sonnet        # Use a specific model
claude --verbose             # Show detailed tool calls
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Enter` | Send message |
| `Shift+Enter` | New line in prompt |
| `Ctrl+C` | Interrupt Claude's response |
| `Shift+Tab` | Cycle permission modes (plan → auto → default...) |
| `Ctrl+L` | Clear screen |
| `@filename` | Reference a file in your prompt |
| `/` | Open slash command menu |

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/help` | Show all commands |
| `/init` | Generate CLAUDE.md for your project |
| `/compact` | Summarize context to free up space |
| `/memory` | View/edit auto-saved memory |
| `/clear` | Clear session |

Custom skills are also slash commands (e.g., `/review`, `/add-endpoint`).

## File Reference

### CLAUDE.md — Project Instructions

```
./CLAUDE.md                    # Project (shared via git)
./.claude/CLAUDE.md            # Alt project location
~/.claude/CLAUDE.md            # User (personal, all projects)
```

What to include:
- Build/test/lint commands
- Code conventions
- Architecture overview
- Common workflows

### Settings — Enforce Behavior

```
.claude/settings.json          # Project (shared via git)
.claude/settings.local.json    # Local (gitignored)
~/.claude/settings.json        # User (personal)
```

```json
{
  "permissions": {
    "allow": ["Read", "Bash(uv run pytest *)"],
    "deny": ["Edit(.env*)", "Bash(rm -rf *)"]
  }
}
```

### Hooks — Automation

Defined in settings.json under `"hooks"`:

| Event | When | Exit 0 | Exit 2 |
|-------|------|--------|--------|
| `PreToolUse` | Before tool runs | Proceed | Block |
| `PostToolUse` | After tool succeeds | Continue | — |
| `Notification` | Needs attention | — | — |
| `SessionStart` | Session begins | Inject stdout | — |

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "uv run ruff format $(cat | jq -r '.tool_input.file_path')"
      }]
    }]
  }
}
```

### Skills — Custom Slash Commands

```
.claude/skills/<name>/SKILL.md     # Project
~/.claude/skills/<name>/SKILL.md   # User
```

```yaml
---
name: my-skill
description: What it does
argument-hint: "[file-or-directory]"    # autocomplete hint
allowed-tools: Read, Edit, Bash         # restrict tool access
model: sonnet                           # model override
effort: high                            # low | medium | high | max
disable-model-invocation: false         # true = pure shell, no AI
user-invocable: true                    # false = hidden from /menu
context: fork                           # run in forked subagent
agent: general-purpose                  # subagent type for context: fork
paths:                                  # auto-load for matching files
  - "src/**/*.py"
---

Prompt here. Use $ARGUMENTS for user input.
Dynamic context: !`git log --oneline -5`
```

### Agents — Specialized Subagents

```
.claude/agents/<name>.md           # Project
~/.claude/agents/<name>.md         # User
```

```yaml
---
name: my-agent
description: What it does
tools: Read, Grep, Glob               # allowed tools
disallowedTools: Write, Edit           # denied tools
model: haiku                           # sonnet | opus | haiku | inherit
effort: low                            # low | medium | high | max
maxTurns: 10                           # limit agentic turns
memory: project                        # user | project | local
skills: review, test-coverage          # preload skills
permissionMode: default                # default | plan | acceptEdits
background: false                      # true = always run in background
isolation: worktree                    # run in isolated git worktree
---

System prompt for the agent.
```

Built-in agents: **Explore** (search, haiku), **Plan** (design, read-only)

### MCP Servers — External Tools

```
.mcp.json                          # Project (shared)
~/.claude.json                     # User / local (personal)
```

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic-ai/github-mcp"]
    }
  }
}
```

## Permission Rules Cheat Sheet

```
"Read"                    # All reads
"Edit(src/**/*.py)"       # Edits to Python in src/
"Bash(uv run pytest *)"   # pytest with any args
"Bash(git *)"             # all git commands
"Write(tests/*)"          # new files in tests/
```

## Common Patterns

**Ask Claude to explore before implementing:**
```
"Explain how task filtering works before making changes"
```

**Use plan mode for design:**
```
Press Shift+Tab to cycle to plan mode → "Design a caching layer for the database" → Shift+Tab to cycle back
```

**Reference files directly:**
```
"Look at @src/taskflow/models.py and add a due_date field"
```

**Free up context in long sessions:**
```
/compact
```

**Parallel agent work:**
```
"Review the task router AND write tests for the user endpoints - do both at the same time"
```

**Non-interactive for CI:**
```bash
claude -p "Run tests and report failures" --allowedTools '["Bash","Read"]' --output-format json
```
