# Exercise 4: Hooks - Automation & Guardrails

## Goal
Learn to use hooks to automate actions and enforce guardrails around Claude's tool usage.

## Concepts

### What are Hooks?
Shell commands that run automatically at specific points in Claude's workflow.
Unlike CLAUDE.md (suggestions), hooks **enforce** through code execution.

### Key Hook Events
| Event | When | Use For |
|-------|------|---------|
| `PreToolUse` | Before a tool runs | Block dangerous actions, validate input |
| `PostToolUse` | After a tool succeeds | Auto-format, lint, log |
| `Notification` | Claude needs attention | Desktop/Slack notifications |
| `SessionStart` | Session begins | Load env vars, inject context |
See more https://code.claude.com/docs/en/hooks-guide#how-hooks-work.

### Hook I/O
- **Input**: JSON on stdin with tool name, input, session info
- **Exit 0**: Proceed normally
- **Exit 2**: Block the action (stderr becomes Claude's feedback)

## Tasks

### 4.1 - See Hooks in Action
This project has two hooks pre-configured. Look at `.claude/settings.json`:

1. **PostToolUse (Edit|Write)**: Auto-formats Python files with `ruff`
2. **PreToolUse (Edit|Write)**: Blocks hardcoded secrets

Test the auto-formatter:
```
Ask Claude: "Add a function to utils.py with bad formatting - no spaces around equals signs, wrong import order"
```
Watch: After Claude writes the file, ruff auto-formats it.

### 4.2 - Test the Secret Blocker
```
Ask Claude: "Add a constant API_KEY = 'sk-1234567890abcdef' to utils.py"
```
The hook should block this write with a warning.

Look at the hook script:
```bash
cat .claude/hooks/check-secrets.sh
```

### 4.3 - Create a New Hook: Test Runner
Add a hook that runs tests after any Python file is edited:

Edit `.claude/settings.json` and add to the `PostToolUse` array:
```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "file_path=$(cat | jq -r '.tool_input.file_path // empty'); if [[ \"$file_path\" == *.py ]]; then cd $CLAUDE_PROJECT_DIR && uv run pytest --tb=short -q 2>&1 | tail -5; fi; exit 0"
    }
  ]
}
```

Now ask Claude to make a change - tests run automatically!

### 4.4 - Create a Notification Hook
Add to your user settings (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '🔔 Claude needs your attention' >&2"
          }
        ]
      }
    ]
  }
}
```

## Key Takeaways
- Hooks enforce rules that CLAUDE.md can only suggest
- `PreToolUse` + exit 2 = block actions with feedback
- `PostToolUse` = auto-format, lint, test after changes
- Hooks receive JSON on stdin with full context
- Use `$CLAUDE_PROJECT_DIR` for project-relative paths
