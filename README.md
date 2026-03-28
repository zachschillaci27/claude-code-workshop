# Claude Code Workshop

A hands-on workshop to learn Claude Code from beginner to intermediate, built around a real Python FastAPI project.

## What You'll Learn

| # | Exercise | Topic | Time |
|---|----------|-------|------|
| 1 | [Getting Started](exercises/01-getting-started.md) | Launch, explore, make changes | 10 min |
| 2 | [CLAUDE.md](exercises/02-claude-md.md) | Project instructions & context | 10 min |
| 3 | [Settings & Permissions](exercises/03-settings-and-permissions.md) | Configure behavior & access control | 10 min |
| 4 | [Hooks](exercises/04-hooks.md) | Automation & guardrails | 10 min |
| 5 | [Skills](exercises/05-skills.md) | Custom slash commands | 10 min |
| 6 | [Agents](exercises/06-agents.md) | Specialized subagents | 10 min |
| 7 | [MCP Servers](exercises/07-mcp-servers.md) | External integrations | 5 min |
| 8 | [Real-World Workflow](exercises/08-real-world-workflow.md) | Putting it all together | 15 min |

**Total time: ~80 minutes**

## Prerequisites

- Python 3.11+
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A terminal (macOS, Linux, or WSL on Windows)

## Quick Start

```bash
# Clone the repo
git clone https://github.com/zachschillaci27/claude-code-workshop.git
cd claude-code-workshop

# Install dependencies
pip install -e ".[dev]"

# Verify setup
pytest

# Start the workshop!
claude
```

## The Demo Project: TaskFlow API

A task management REST API built with FastAPI. It's simple enough to understand in minutes, but has enough surface area to demonstrate all Claude Code features.

### Run the API
```bash
uvicorn taskflow.main:app --reload
# Open http://localhost:8000/docs for interactive API docs
```

### Run Tests
```bash
pytest                                          # all tests
pytest tests/test_tasks.py -v                   # task tests only
pytest tests/test_tasks.py::test_create_task -v # single test
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
- **Permission modes** - Allow/deny rules, plan mode

## Tips for Workshop Facilitators

1. **Start with Exercise 1** - Get everyone running Claude Code successfully
2. **Live code together** - Do exercises 2-4 as a group with screen sharing
3. **Let people explore** - Exercises 5-8 work well as self-paced
4. **Use the bonus challenges** in Exercise 8 for fast learners
5. **Encourage experimentation** - The in-memory database resets on restart, so nothing breaks permanently
