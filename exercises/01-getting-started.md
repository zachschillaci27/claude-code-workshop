# Exercise 1: Getting Started with Claude Code

## Goal
Get familiar with Claude Code basics: launching, navigating, and running commands.

## Setup

Run these commands in a **regular terminal** (not inside Claude Code):
```bash
# Install uv if you don't have it
curl -LsSf https://astral.sh/uv/install.sh | sh

# Clone the repo and install dependencies
git clone https://github.com/zachschillaci27/claude-code-workshop.git
cd claude-code-workshop
uv sync

# Verify everything works
uv run pytest
```

## Tasks

### 1.1 - Launch Claude Code
```bash
claude
```
Try these basic interactions:
- Ask: "What does this project do?"
- Ask: "Show me all the API endpoints"
- Ask: "Run the tests"

### 1.2 - Explore the Codebase
Ask Claude to:
- "Explain the architecture of this project"
- "What models are defined in models.py?"
- "How does task filtering work?"

Notice how Claude reads files and uses tools automatically.

### 1.3 - Make a Simple Change
Ask Claude:
- "Add a `description` field to the `/health` endpoint that returns 'TaskFlow health check'"

Watch how Claude:
1. Reads the relevant file
2. Makes the edit
3. Shows you the diff

### 1.4 - @-Mentions: Reference Files Directly
Instead of describing files, point Claude at them:
```
"Look at @src/taskflow/models.py and add a 'due_date' optional field to TaskCreate"
```
The `@` gives Claude immediate context — no searching required.

### 1.5 - Interrupt & Recover
Things go wrong sometimes. Practice these:

1. **Interrupt**: Ask Claude to do something, then press `Ctrl+C` while it's working
2. **Redirect**: Say *"Actually, undo that change"* — Claude can revert its own edits
3. **Multi-line input**: Press `Shift+Enter` to write longer prompts across lines

### 1.6 - Run Tests
Ask Claude:
- "Run the tests and tell me if anything fails"
- "Run just the task endpoint tests"

### 1.7 - Permission Modes
Press `Shift+Tab` to cycle permission modes. Stop at **plan mode** (read-only). Then ask:
```
"How would you add pagination to the user list endpoint?"
```
Claude will design the approach without changing any files. Press `Shift+Tab` to cycle back to default mode.

Note: `Shift+Tab` cycles through modes: plan → auto → default, etc.

### 1.8 - Context Management
As you work, conversation history fills up Claude's context window (~200K tokens).

- Run `/compact` to summarize and free up space
- Use `claude --continue` to resume your last session later
- Use `claude --resume` to pick from previous sessions

## Key Takeaways
- Claude Code reads files before editing them
- It uses tools (Read, Edit, Bash, Grep, Glob) to interact with your codebase
- You approve or deny each action (unless permissions are configured)
- Use `@file` to give Claude immediate context
- `Ctrl+C` to interrupt, plan mode (`Shift+Tab`) to design before implementing
- `/compact` keeps long sessions manageable
