# Exercise 3: Settings & Permissions

## Goal
Learn to configure Claude Code's behavior through settings files and permission rules.

## Concepts

### Settings Files
| Scope | Path | Shared |
|-------|------|--------|
| Project | `.claude/settings.json` | Yes (git) |
| Local | `.claude/settings.local.json` | No (.gitignored) |
| User | `~/.claude/settings.json` | No |

### Permission Rules
```json
{
  "permissions": {
    "allow": ["ToolName(pattern)"],
    "deny": ["ToolName(pattern)"]
  }
}
```

## Tasks

### 3.1 - Inspect Current Settings
```bash
cat .claude/settings.json
```
Notice:
- Which tools are pre-approved (allow list)
- Which are blocked (deny list)
- Hooks configured (we'll cover these in Exercise 4)

### 3.2 - Experience Permissions in Action
Launch Claude and ask it to:
1. "Run the tests" → Should auto-approve (`uv` is in allow list)
2. "Delete all files in src/" → Should be blocked (rm -rf is in deny list)
3. "Install requests" → Should auto-approve (`uv` is allowed)

### 3.3 - Tighten Permissions
Edit `.claude/settings.json` to only allow read-only operations:
```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep"],
    "deny": ["Edit(*)", "Write(*)", "Bash(*)"]
  }
}
```
Now ask Claude to edit a file. What happens?

Restore the original settings when done.

### 3.4 - Add Environment Variables
Add to `.claude/settings.local.json` (create this file):
```json
{
  "env": {
    "TASKFLOW_ENV": "workshop",
    "DEBUG": "true"
  }
}
```
Ask Claude: "Print the TASKFLOW_ENV environment variable"

Note: `.local.json` is gitignored - perfect for personal config and secrets.

## Key Takeaways
- Settings enforce behavior; CLAUDE.md guides behavior
- Use project settings for team-wide rules
- Use local settings for personal overrides
- Permission rules control which tools Claude can use
- `allow` and `deny` use glob patterns for flexible matching
