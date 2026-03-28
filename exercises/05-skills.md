# Exercise 5: Custom Skills (Slash Commands)

## Goal
Create reusable workflows as custom slash commands.

## Concepts

### What are Skills?
Markdown files that define reusable prompts invoked with `/command-name`.
They can accept arguments, inject dynamic data, and restrict tool access.

### File Structure
```
.claude/skills/<skill-name>/SKILL.md
```

### SKILL.md Format
```yaml
---
name: my-skill
description: What this skill does
allowed-tools: Read, Edit, Bash    # optional: restrict tools
---

Prompt template here. Use $ARGUMENTS for user input.
```

## Tasks

### 5.1 - Use the Pre-Built Skills
This project includes three skills. Try them:

```
/review src/taskflow/routers/tasks.py
```
This runs a code review against the project's standards.

```
/test-coverage
```
This analyzes which functions lack tests.

```
/add-endpoint "GET /api/v1/tasks/search - full-text search by title"
```
This scaffolds a new endpoint with tests.

### 5.2 - Create a Debugging Skill
Create `.claude/skills/debug/SKILL.md`:

```yaml
---
name: debug
description: Investigate a bug or error message
allowed-tools: Read, Grep, Glob, Bash
---

# Debug Investigation

Investigate this issue: $ARGUMENTS

## Steps
1. Search the codebase for related code using Grep
2. Read the relevant files
3. Trace the code path that could cause this issue
4. Identify the root cause
5. Suggest a fix with specific code changes

## Output Format
- **Symptom**: What the user sees
- **Root Cause**: Why it happens
- **Fix**: Specific code changes needed
- **Prevention**: How to prevent this in the future
```

Test it:
```
/debug "GET /api/v1/tasks returns 500 when filtering by invalid status"
```

### 5.3 - Create a Skill with Dynamic Context
Create `.claude/skills/changelog/SKILL.md`:

```yaml
---
name: changelog
description: Generate a changelog from recent commits
---

# Generate Changelog

Generate a changelog entry for the latest changes.

**Recent commits:**
!`git log --oneline -10`

**Changed files:**
!`git diff --name-only HEAD~3`

Write a user-friendly changelog entry in Keep a Changelog format.
Group changes under: Added, Changed, Fixed, Removed.
```

The `!`command`` syntax runs before Claude sees the prompt, injecting live data.

### 5.4 - Create a Skill with No AI (Direct Execution)
```yaml
---
name: status
description: Show project status dashboard
disable-model-invocation: true
---

!`echo "=== TaskFlow Status ==="`
!`echo "Tests:" && pytest --tb=no -q 2>&1 | tail -1`
!`echo "Lint:" && ruff check src/ 2>&1 | tail -1`
!`echo "Files:" && find src -name "*.py" | wc -l`
!`echo "Lines:" && wc -l src/taskflow/*.py src/taskflow/routers/*.py | tail -1`
```

`disable-model-invocation: true` means Claude doesn't process the output - it just runs the commands and shows results.

## Key Takeaways
- Skills package prompts into reusable `/commands`
- `$ARGUMENTS` passes user input to the skill
- `!`command`` injects live data before Claude processes
- `allowed-tools` restricts what the skill can do
- `disable-model-invocation` creates pure shell scripts
- Skills can be project-level (shared) or user-level (personal)
