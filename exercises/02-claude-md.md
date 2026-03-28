# Exercise 2: CLAUDE.md - Project Instructions

## Goal
Understand how CLAUDE.md gives Claude persistent context about your project.

## Concepts

### What is CLAUDE.md?
A markdown file that Claude reads at the start of every session. It tells Claude:
- How to build and test your project
- Code conventions to follow
- Architecture overview
- Common workflows

### Scopes (loaded in order)
| Scope | Path | Shared via |
|-------|------|-----------|
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Git |
| User | `~/.claude/CLAUDE.md` | Not shared |
| Local | `.claude/CLAUDE.local.md` | Not shared (.gitignored) |

## Tasks

### 2.1 - Read the Existing CLAUDE.md
```bash
cat CLAUDE.md
```
Then launch Claude and ask: "What are the project's code conventions?"

Notice it answers from CLAUDE.md without reading any source files.

### 2.2 - Test CLAUDE.md Effectiveness
Ask Claude: "Create a new utility function called `format_task_id` that takes an integer and returns a string like `TASK-001`"

Check: Does Claude follow the conventions in CLAUDE.md?
- Type hints? ✓/✗
- Placed in utils.py? ✓/✗
- Style matches existing code? ✓/✗

### 2.3 - Add a New Convention
Edit CLAUDE.md to add:
```markdown
## Error Handling
- Always use `HTTPException` from FastAPI for error responses
- Include a `detail` field with a human-readable message
- Log errors with `import logging; logger = logging.getLogger(__name__)`
```

Now ask Claude: "Add error logging to the task creation endpoint"

Does it follow your new convention?

### 2.4 - Use /init to Generate CLAUDE.md
Delete the existing CLAUDE.md and run:
```bash
claude /init
```
Compare what Claude generates vs what we had. What did it discover automatically?

## Key Takeaways
- CLAUDE.md is the most important file for Claude Code productivity
- It should contain build commands, conventions, and architecture
- Claude follows these instructions across all sessions
- Use `/init` to bootstrap, then customize
