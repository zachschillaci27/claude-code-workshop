# Exercise 6: Subagents - Specialized Delegation

## Goal
Understand how Claude delegates tasks to specialized subagents with isolated contexts.

## Concepts

### What are Subagents?
Specialized AI assistants that run in separate contexts with their own:
- System prompts
- Tool restrictions
- Model selection (can use faster/cheaper models)

### Built-In Agents
| Agent | Tools | Speed | Use For |
|-------|-------|-------|---------|
| Explore | Read-only | Fast (Haiku) | Search, understand code |
| Plan | Read-only | Normal | Design implementation strategy |
| general-purpose | All tools | Normal | Complex multi-step tasks |

### Custom Agents
```
.claude/agents/<name>.md
```

## Tasks

### 6.1 - Watch Built-In Agents
Ask Claude a broad exploration question:
```
"How does the task filtering system work end-to-end, from the HTTP request to the database query?"
```

Watch the output - Claude will spawn an **Explore** agent to search the codebase.
Notice it uses a faster model and read-only tools.

### 6.2 - Use the Custom Researcher Agent
This project includes a `researcher` agent. Ask Claude:
```
"Use the researcher agent to find all places where tasks are created in the codebase"
```

Look at `.claude/agents/researcher.md` to see how it's configured:
- Model: haiku (fast and cheap)
- Tools: Read, Grep, Glob only (no edits)

### 6.3 - Use the Reviewer Agent
Ask Claude:
```
"Use the reviewer agent to review my recent changes"
```

Or run an entire session as the reviewer:
```bash
claude --agent reviewer
```

### 6.4 - Create a Test Writer Agent
Create `.claude/agents/test-writer.md`:

```yaml
---
name: test-writer
description: Write comprehensive tests for Python code. Use when you need thorough test coverage.
tools: Read, Write, Edit, Glob, Grep, Bash
model: sonnet
---

You are a test engineering specialist for the TaskFlow project.

When asked to write tests:

1. Read the source code to understand what to test
2. Read existing tests in `tests/` for patterns and fixtures
3. Use the `client` fixture from `conftest.py` for endpoint tests
4. Write tests covering:
   - Happy path (normal operation)
   - Error cases (404, 409, validation errors)
   - Edge cases (empty input, max length, special characters)
   - Boundary conditions (pagination limits)

Test naming: `test_<action>_<scenario>` (e.g., `test_create_task_with_empty_title`)

Always run `uv run pytest -v` after writing tests to verify they pass.
```

Test it:
```
"Use the test-writer agent to add comprehensive tests for the user endpoints"
```

### 6.5 - Parallel Agent Execution
Ask Claude to do something that benefits from parallelism:
```
"Review the task router AND analyze test coverage for the user endpoints - do both at the same time"
```

Watch Claude spawn multiple agents in parallel.

## Key Takeaways
- Subagents isolate work and protect the main context window
- Use `model: haiku` for fast, cheap research tasks
- Custom agents define specialized roles with restricted tools
- Claude automatically delegates to built-in agents (Explore, Plan)
- Agents run in parallel when tasks are independent
