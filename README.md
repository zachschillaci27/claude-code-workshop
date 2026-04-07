# Claude Code Workshop

A hands-on workshop to learn Claude Code from beginner to intermediate, built around a real Python FastAPI project.

## What You'll Learn

| # | Exercise | Topic |
|---|----------|-------|
| 1 | [Getting Started](exercises/01-getting-started.md) | Launch, explore, make changes |
| 2 | [CLAUDE.md](exercises/02-claude-md.md) | Project instructions & context |
| 3 | [Settings & Permissions](exercises/03-settings-and-permissions.md) | Configure behavior & access control |
| 4 | [Hooks](exercises/04-hooks.md) | Automation & guardrails |
| 5 | [Skills](exercises/05-skills.md) | Custom slash commands |
| 6 | [Agents](exercises/06-agents.md) | Specialized subagents |
| 7 | [MCP Servers](exercises/07-mcp-servers.md) | External integrations |
| 8 | [Context Management](exercises/08-context-management.md) | Managing context & tool usage |
| 9 | [Real-World Workflow](exercises/09-real-world-workflow.md) | Putting it all together |

## Prerequisites

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) installed (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- [Claude Code](https://code.claude.com/docs/) installed and authenticated
- A terminal (macOS, Linux, or WSL on Windows)

## Quick Start

```bash
# Clone the repo
git clone https://github.com/zachschillaci27/claude-code-workshop.git
cd claude-code-workshop

# Install dependencies
uv sync

# Verify setup
uv run pytest

# Start the workshop!
claude
```

## The Demo Project: TaskFlow API

A task management REST API built with FastAPI. It's simple enough to understand in minutes, but has enough surface area to demonstrate all Claude Code features.

### Run the API
```bash
uv run uvicorn taskflow.main:app --reload
# Open http://localhost:8000/docs for interactive API docs
```

### Run Tests
```bash
uv run pytest                                          # all tests
uv run pytest tests/test_tasks.py -v                   # task tests only
uv run pytest tests/test_tasks.py::test_create_task -v # single test
```

### Project Structure
```
src/taskflow/
├── main.py              # FastAPI app entry point
├── models.py            # Pydantic request/response models
├── database.py          # In-memory database with seed data
├── utils.py             # Helper functions
└── routers/
    ├── tasks.py         # Task CRUD endpoints
    └── users.py         # User endpoints

tests/
├── conftest.py          # Shared fixtures
├── test_tasks.py        # Task endpoint tests
├── test_models.py       # Model validation tests
└── test_utils.py        # Utility function tests
```

### Claude Code Configuration (included)
```
CLAUDE.md                          # Project instructions
.claude/
├── settings.json                  # Permissions & hooks
├── hooks/
│   └── check-secrets.sh           # Blocks hardcoded secrets
├── skills/
│   ├── review/SKILL.md            # /review - Code review
│   ├── add-endpoint/SKILL.md      # /add-endpoint - Scaffold endpoints
│   └── test-coverage/SKILL.md     # /test-coverage - Coverage analysis
└── agents/
    ├── researcher.md              # Read-only research agent
    └── reviewer.md                # Code review agent
.mcp.json                          # MCP server config (GitHub)
```

## Feature Coverage

This workshop covers the following Claude Code features:

- **CLAUDE.md** - Project-level, user-level, and nested instructions
- **Settings** - Project, local, and user settings with permission rules
- **Hooks** - PreToolUse, PostToolUse, Notification events with shell scripts
- **Skills** - Custom slash commands with arguments and dynamic context
- **Agents** - Custom subagents with tool restrictions and model selection
- **MCP Servers** - External integrations (GitHub example)
- **Built-in tools** - Read, Edit, Write, Bash, Grep, Glob
- **Built-in commands** - /init, /compact, /memory, /help
- **Permission modes** - Allow/deny rules, plan mode (via `Shift+Tab` cycling)