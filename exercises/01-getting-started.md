# Exercise 1: Getting Started with Claude Code

## Goal
Get familiar with Claude Code basics: launching, navigating, and running commands.

## Setup
```bash
# Clone the repo and install dependencies
git clone https://github.com/zachschillaci27/claude-code-workshop.git
cd claude-code-workshop
pip install -e ".[dev]"

# Verify everything works
pytest
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

### 1.4 - Run Tests
Ask Claude:
- "Run the tests and tell me if anything fails"
- "Run just the task endpoint tests"

## Key Takeaways
- Claude Code reads files before editing them
- It uses tools (Read, Edit, Bash, Grep, Glob) to interact with your codebase
- You approve or deny each action (unless permissions are configured)
