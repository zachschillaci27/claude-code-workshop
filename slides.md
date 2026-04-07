---
marp: true
theme: default
paginate: true
backgroundColor: #1a1a2e
color: #e0e0e0
style: |
  section {
    font-family: 'Inter', 'Helvetica Neue', sans-serif;
  }
  h1 {
    color: #d4a574;
  }
  h2 {
    color: #c49a6c;
  }
  h3 {
    color: #b0b0b0;
  }
  code {
    background: #2d2d44;
    color: #e8c47c;
  }
  pre {
    background: #16162a !important;
    border-left: 3px solid #d4a574;
  }
  a {
    color: #7eb8da;
  }
  table {
    font-size: 0.85em;
  }
  th {
    background: #2d2d44;
    color: #d4a574;
  }
  td {
    background: #1e1e36;
  }
  strong {
    color: #e8c47c;
  }
  blockquote {
    border-left: 4px solid #d4a574;
    background: #1e1e36;
    color: #b0b0b0;
  }
  .columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1em;
  }
---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _backgroundColor: #0f0f1e -->

# Claude Code Workshop

### From Beginner to Intermediate

<br>

An interactive, hands-on session with a real codebase

<br>

**~85 minutes** &bull; 8 exercises &bull; Live coding

---

## Agenda

| Part | Topics | Time |
|------|--------|------|
| **1. Foundations** | Launch, explore, edit, recover | 25 min |
| **2. Configuration** | CLAUDE.md, settings, permissions | 20 min |
| **3. Automation** | Hooks, custom skills | 20 min |
| **4. Advanced** | Subagents, context, real-world workflow | 15 min |
| **Wrap-up** | Quick wins, Q&A | 5 min |

<br>

> All exercises use **TaskFlow** — a Python FastAPI task management API

---

## Setup Check

```bash
# Should all work before we start
claude --version         # Claude Code installed
python --version         # Python 3.11+
uv --version             # uv package manager

# Clone and install
git clone https://github.com/zachschillaci27/claude-code-workshop.git
cd claude-code-workshop
uv sync
uv run pytest            # 18 tests should pass
```

---

<!-- _class: lead -->
<!-- _backgroundColor: #0f0f1e -->

# Part 1
## Foundations

---

# Exercise 1 — Getting Started

### What is Claude Code?

- An **agentic** coding assistant in your terminal
- Not autocomplete — it takes **multi-step actions**
- Reads, searches, edits files, runs commands
- **You approve** each action (unless configured otherwise)

<br>

```bash
claude
```

---

## Core Tools

Claude uses these tools to interact with your codebase:

| Tool | Purpose |
|------|---------|
| **Read** | Read file contents |
| **Edit** | Modify existing files |
| **Write** | Create new files |
| **Bash** | Run shell commands |
| **Grep** | Search file contents |
| **Glob** | Find files by pattern |

You'll see these in action as Claude works.

---

## Try It

```
"What does this project do?"
```

```
"Show me all the API endpoints"
```

```
"Run the tests"
```

```
"Add a description field to the /health endpoint"
```

Watch how Claude **reads first, then edits**, and asks for permission.

---

## Essential Navigation

**@-mentions** — Point Claude at a file directly:
```
"Look at @src/taskflow/models.py and add a due_date field"
```

**Interrupt** — `Ctrl+C` stops Claude mid-action

**Multi-line** — `Shift+Enter` for longer prompts

**Permission modes** — `Shift+Tab` cycles through:
`default` → `acceptEdits` → `plan` → ...

> **Plan mode** = read-only. Claude designs but doesn't change anything.

---

## Context Management

Claude has a **~200K token** context window that fills as you work.

| Command | What it does |
|---------|-------------|
| `/compact` | Summarize conversation, free up space |
| `claude --continue` | Resume your last session |
| `claude --resume` | Pick from previous sessions |

<br>

> Use `/compact` between major tasks to keep sessions fresh

---

<!-- _class: lead -->
<!-- _backgroundColor: #0f0f1e -->

# Part 2
## Configuration

---

# Exercise 2 — CLAUDE.md

### The single most impactful file for productivity

Claude reads it at the **start of every session**. It tells Claude:

- How to **build and test** your project
- **Code conventions** to follow
- **Architecture** overview
- Common **workflows**

<br>

```
./CLAUDE.md               # Project (shared via git)
./.claude/CLAUDE.md       # Alt location
~/.claude/CLAUDE.md       # User (personal, all projects)
```

---

## What to Put in CLAUDE.md

```markdown
# TaskFlow API

## Build & Run
- Install: `uv sync`
- Run server: `uv run uvicorn taskflow.main:app --reload`
- Run tests: `uv run pytest`
- Lint: `uv run ruff check src/ tests/`

## Code Conventions
- Use type hints on all function signatures
- Prefer `str | None` over `Optional[str]`
- Keep endpoint handlers thin — logic in database layer

## Architecture
- `src/taskflow/main.py` — FastAPI app entry point
- `src/taskflow/models.py` — Pydantic models
- `src/taskflow/routers/` — Endpoint handlers
```

---

## The Effect

Without CLAUDE.md:
> Claude guesses at conventions, might use wrong commands

With CLAUDE.md:
> Claude follows your team's standards automatically

<br>

**Try it:**
```
"Create a new endpoint to get tasks by tag"
```
→ Check: Type hints? `/api/v1/` prefix? 404 handling? Thin handler?

<br>

**Bootstrap with:** `/init` — Claude analyzes your codebase and generates one

---

# Exercise 3 — Settings & Permissions

### Settings enforce behavior. CLAUDE.md guides behavior.

```
.claude/settings.json           # Project (shared via git)
.claude/settings.local.json     # Local (gitignored)
~/.claude/settings.json         # User (personal)
```

<br>

### The mental model

| Rule | Effect |
|------|--------|
| `allow` | Auto-approve — no permission prompt |
| `deny` | Block entirely — Claude gets error feedback |
| *(neither)* | Prompt the user each time |

---

## Permission Rules

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(uv *)", "Bash(git *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Edit(.env*)"
    ]
  }
}
```

**Pattern syntax:** `ToolName(glob pattern)`

```
"Bash(uv run pytest *)"      # pytest with any args
"Edit(src/**/*.py)"           # edits to Python in src/
"Write(tests/*)"              # new files in tests/
```

---

<!-- _class: lead -->
<!-- _backgroundColor: #0f0f1e -->

# Part 3
## Automation

---

# Exercise 4 — Hooks

### Shell commands that run at specific points in Claude's workflow

Unlike CLAUDE.md (suggestions), hooks **enforce through code**.

| Event | When | Use For |
|-------|------|---------|
| `PreToolUse` | Before a tool runs | Block dangerous actions |
| `PostToolUse` | After a tool succeeds | Auto-format, lint |
| `Notification` | Claude needs attention | Desktop alerts |
| `SessionStart` | Session begins | Load env vars |

<br>

**Exit code 0** = proceed &nbsp;&nbsp; **Exit code 2** = block (stderr → Claude)

---

## Hook Examples in This Project

### Auto-format after every edit
```json
{
  "PostToolUse": [{
    "matcher": "Edit|Write",
    "hooks": [{
      "type": "command",
      "command": "... ruff format ... ruff check --fix ..."
    }]
  }]
}
```

### Block hardcoded secrets
```bash
# .claude/hooks/check-secrets.sh
# Reads JSON from stdin, checks for password/token patterns
# Exit 2 to block, stderr becomes Claude's feedback
```

---

## Demo: Hooks in Action

**Auto-format:**
```
"Add a function to utils.py with really bad formatting"
```
→ ruff fixes it automatically after Claude writes

<br>

**Secret blocker:**
```
"Add DATABASE_URL = 'postgresql://admin:secret@prod:5432/db' to database.py"
```
→ Hook blocks the write! Claude gets feedback.

<br>

> Hooks receive JSON on stdin with `tool_name`, `tool_input`, `session_id`

---

# Exercise 5 — Custom Skills

### Reusable workflows as `/slash-commands`

```
.claude/skills/<name>/SKILL.md     # Project
~/.claude/skills/<name>/SKILL.md   # User
```

```yaml
---
name: review
description: Review code for quality and security
argument-hint: "[file-or-directory]"
allowed-tools: Read, Grep, Glob
model: sonnet
effort: high
---

Review $ARGUMENTS against the project's coding standards.
...
```

---

## Skill Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `name` | Slash command identifier |
| `description` | When to use (shown in `/` menu) |
| `argument-hint` | Autocomplete hint, e.g. `"[filename]"` |
| `allowed-tools` | Restrict tool access |
| `model` / `effort` | Cost/quality tradeoffs |
| `disable-model-invocation` | `true` = pure shell, no AI |
| `user-invocable` | `false` = hidden from menu |
| `context: fork` + `agent` | Delegate to a subagent |
| `paths` | Auto-load only for matching files |

---

## Try the Pre-Built Skills

```
/review src/taskflow/routers/tasks.py
```
→ Structured code review against project standards

```
/test-coverage
```
→ Finds untested functions, suggests test cases

```
/add-endpoint "GET /api/v1/tasks/search - search by title"
```
→ Scaffolds endpoint + database method + tests

<br>

**Dynamic context:** `` !`git log --oneline -5` `` injects live data into the prompt

---

<!-- _class: lead -->
<!-- _backgroundColor: #0f0f1e -->

# Part 4
## Advanced

---

# Exercise 6 — Subagents

### Specialized AI assistants with isolated contexts

| Built-in | Model | Tools | Use For |
|----------|-------|-------|---------|
| **Explore** | Haiku (fast) | Read-only | Search, analyze |
| **Plan** | Inherited | Read-only | Design strategy |
| **general-purpose** | Inherited | All | Complex tasks |

Custom agents go in:
```
.claude/agents/<name>.md           # Project
~/.claude/agents/<name>.md         # User
```

---

## Agent Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `name` / `description` | Identity (required) |
| `tools` / `disallowedTools` | Allow/deny tools |
| `model` | `haiku`, `sonnet`, `opus`, `inherit` |
| `effort` | `low`, `medium`, `high`, `max` |
| `maxTurns` | Limit agentic turns |
| `memory` | `user`, `project`, `local` — persistent learning |
| `skills` | Preload skills into context |
| `permissionMode` | `default`, `plan`, `acceptEdits` |
| `isolation` | `worktree` — isolated git worktree |
| `background` | `true` = always run in background |

---

## This Project's Agents

**Researcher** — fast, cheap, read-only
```yaml
model: haiku
effort: low
maxTurns: 10
memory: project         # learns across sessions
disallowedTools: Write, Edit, Bash
```

**Reviewer** — thorough code review
```yaml
model: sonnet
effort: high
maxTurns: 15
skills: review          # preloads /review skill
disallowedTools: Write, Edit
```

---

# Exercise 7 — MCP Servers

### Connect Claude to external tools and services
> External MCP servers require network access — may be restricted by sandbox policies

```json
// .mcp.json (project root)
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

| Scope | Path |
|-------|------|
| Project (shared) | `.mcp.json` |
| User / Local | `~/.claude.json` |

---

# Exercise 8 — Real-World Workflow

### Putting it all together

```
"Add a search endpoint for tasks — case-insensitive
 substring match on title and description via query param 'q'.
 Update the database layer, the endpoint, and add tests."
```

Watch Claude:
1. **Branch** — create feature branch
2. **Read** existing code (Grep, Read)
3. **Plan** the approach (may use Plan agent)
4. **Edit** database.py (hook: auto-formats)
5. **Edit** tasks.py (hook: auto-formats)
6. **Write** tests
7. **Run** tests (Bash)
8. **Commit & push** — then open a PR for review

> Branch workflow + CLAUDE.md conventions + hooks + multi-file coordination

---

<!-- _class: lead -->
<!-- _backgroundColor: #0f0f1e -->

# Wrap-Up

---

## Quick Wins to Take Home

### Today
1. **Add `CLAUDE.md`** to your projects — biggest ROI, 5 minutes

### This Week
2. **Configure settings** — allow `pytest`/`git`, deny `rm -rf`/`.env`
3. **Create one skill** for your most repeated workflow

### This Month
4. **Add hooks** — auto-format, secret detection
5. **Create custom agents** for your team's review/research needs

---

## The Configuration Landscape

| Feature | File | Guides vs Enforces |
|---------|------|--------------------|
| **CLAUDE.md** | `./CLAUDE.md` | Guides |
| **Settings** | `.claude/settings.json` | Enforces |
| **Hooks** | In settings.json | Enforces |
| **Skills** | `.claude/skills/*/SKILL.md` | Guides |
| **Agents** | `.claude/agents/*.md` | Both |
| **MCP** | `.mcp.json` | Extends |

<br>

**Rule of thumb:** Instructions in CLAUDE.md, enforcement in settings/hooks.

---

## Resources

- **Docs:** https://code.claude.com/docs/
- **Cheat sheet:** `CHEATSHEET.md` in this repo
- **Report issues:** https://github.com/anthropics/claude-code/issues
- **Exercises:** `exercises/` directory for self-paced review

<br>

### Platforms
Terminal &bull; VS Code extension &bull; JetBrains plugin &bull; Web app

---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _backgroundColor: #0f0f1e -->

# Questions?

<br>

```bash
claude
> "What should I ask about Claude Code?"
```
