# Exercise 8: Context Management

## Goal
Understand how Claude's context window fills up, how to monitor it, and how to keep
sessions productive across long tasks.

## Concepts

### The Context Window
Claude has a **~200K token** context window. Every turn adds to it:

| What consumes tokens | Rough cost |
|---|---|
| Your messages | Low |
| Claude's responses | Medium |
| File reads (Read tool) | Varies — large files are expensive |
| Bash output (stdout/stderr) | Can be very large if unbounded |
| Tool call results from MCP servers | Varies by server |
| Conversation history | Accumulates every turn |

Once the window fills, Claude either auto-compacts or starts losing earlier context.
Tool selection accuracy also degrades as the window fills.

### /context — Check Usage
```
/context
```
Shows your current context window usage as a percentage. Run this periodically during
long sessions to know how much headroom you have left.

### /compact — Free Up Space
```
/compact
```
Summarizes the entire conversation into a compact representation and replaces the raw
history. Useful between major tasks — Claude retains the gist but the raw tool outputs
and file contents are gone.

You can also provide a custom summary instruction:
```
/compact Focus on the database layer changes we made
```

### Auto-Compaction
When context reaches ~95%, Claude Code automatically compacts without prompting.
Auto-compaction is less targeted than manual `/compact` — it summarizes everything it
can, which may drop details you still need. This is why proactive `/compact` between
tasks is better than waiting.

### /memory — Persistent Memory
```
/memory
```
Opens the auto-memory files for your current project in your editor. Auto-memory lets
Claude remember facts, preferences, and decisions **across sessions**.

How it works:
- Claude writes to `~/.claude/projects/<project-path>/memory/`
- A `MEMORY.md` index file links all memory entries (≤200 lines — lines after 200 are truncated)
- Each entry is a small `.md` file with frontmatter (`type`, `name`, `description`)
- Memory types: `user`, `feedback`, `project`, `reference`

Memory is loaded at the start of every session. To disable:
```
/memory toggle
```

Or in settings:
```json
{ "autoMemoryEnabled": false }
```

> **What to save vs. not save:** Memory is for facts that are non-obvious and persist
> across sessions (user preferences, project decisions, reference links). Don't save
> things already in git history or derivable from reading the code.

### Session Resume
When you close Claude Code and come back:

```bash
claude --continue        # Resume your last session
claude --resume          # Pick from a list of recent sessions
```

Resumed sessions reload the conversation history and memory, but the context window
starts fresh — so you may need to re-read files Claude previously had in context.

## Tasks

### 9.1 - Check Your Current Context Usage
Inside a Claude Code session, run:
```
/context
```
Note the percentage. Then ask Claude to read a few large files and check again:
```
"Read all the files in src/taskflow/"
```
```
/context
```
Observe how file reads move the needle.

### 9.2 - Compact Between Tasks
After completing a feature or bug fix, run:
```
/compact
```
Then verify Claude still remembers the key decisions:
```
"What did we just change and why?"
```
Claude should give a coherent summary even though the raw history is gone.

### 9.3 - Inspect Auto-Memory
```
/memory
```
This opens your memory files. Look at `MEMORY.md` — it's the index loaded every session.

Ask Claude to save something explicitly:
```
"Remember that we use uv for all Python commands in this project, never pip"
```
Then check `/memory` again — a new entry should appear.

### 9.4 - Simulate Context Pressure
Ask Claude to do something context-heavy in one session:
```
"Read every file in the project, explain each one, then summarize the whole architecture"
```
Watch `/context` climb. When it gets above 70%, run `/compact` and compare the
percentage before and after.

### 9.5 - Resume a Session
Exit Claude Code (`/exit` or `Ctrl+D`), then re-enter:
```bash
claude --continue
```
Ask:
```
"What were we working on?"
```
Claude should reconstruct context from the session history and memory.

## Practical Strategies

| Situation | Strategy |
|---|---|
| Starting a new major task | `/compact` first to clear previous task noise |
| Context above ~70% | `/compact` proactively, don't wait for auto-compact |
| Context above ~90% | Start a new session (`claude --continue` to resume) |
| Long-running research task | Use an Explore subagent — it has its own isolated context |
| Repeated conventions Claude keeps forgetting | Add to `/memory` or CLAUDE.md |
| Working across many files | Use @-mentions to load specific files rather than broad reads |

## Key Takeaways
- `/context` shows real-time context usage — check it during long sessions
- `/compact` manually summarizes history; do it proactively between major tasks
- Auto-compaction triggers at ~95% — less precise than manual compact
- Auto-memory (`/memory`) persists facts across sessions in `~/.claude/projects/*/memory/`
- `MEMORY.md` is the session index — keep it under 200 lines
- `claude --continue` / `--resume` restores session history but not the context window
- Subagents have isolated contexts — use them to protect the main session from large reads
