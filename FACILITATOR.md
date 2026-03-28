# Facilitator Guide

Step-by-step presenter guide for the Claude Code workshop. Times are approximate - adjust based on audience pace.

---

## Before the Workshop

### Setup Checklist
- [ ] All participants have Claude Code installed and authenticated (`claude --version`)
- [ ] Python 3.11+ installed (`python --version`)
- [ ] Repo cloned and dependencies installed (`pip install -e ".[dev]"`)
- [ ] Tests pass (`pytest`)
- [ ] Terminal visible on projector/screen share (use large font: 16pt+)

### Environment Tips
- Use a clean terminal with minimal prompt noise
- Have the repo open in your preferred editor alongside the terminal
- Keep `exercises/` open for reference as you go
- Consider split-screen: editor left, Claude Code right

---

## Part 1: Foundations (25 min)

### 1A - What is Claude Code? (5 min) — TALK

**Talking points:**
- Claude Code is an agentic coding assistant that runs in your terminal
- It can read, search, edit files, run commands — with your approval
- Think of it as a senior developer pair-programming with you
- It's not autocomplete — it's an agent that takes multi-step actions

**Live demo:**
```bash
# Launch Claude Code in the project
cd claude-code-workshop
claude
```

Ask: *"What does this project do?"*

Point out:
- Claude reads files automatically (show the tool calls)
- It synthesizes across multiple files
- The answer references specific files and structure

### 1B - Basic Interactions (10 min) — LIVE CODING

**Demo these prompts one by one, pausing to explain what's happening:**

```
"Show me all the API endpoints"
```
→ Point out: Claude uses Grep/Glob to search, then Read to understand

```
"Run the tests"
```
→ Point out: Claude uses Bash tool, you approve/deny the command

```
"Add a description field to the /health endpoint that returns 'TaskFlow health check'"
```
→ Point out: Claude reads the file first, then makes a surgical edit

```
"Run the tests again to make sure I didn't break anything"
```
→ Point out: This is the basic workflow loop — change, verify, iterate

**Key moment:** Show the permission prompt. Explain that Claude asks before acting.

### 1C - Navigation & Error Recovery (10 min) — LIVE CODING

**Demo these essential interactions:**

**@-mentions** — Reference files directly in your prompt:
```
"Look at @src/taskflow/models.py and add a 'due_date' optional field to TaskCreate"
```
→ Point out: `@` gives Claude immediate context without searching

**Interrupt & redirect:**
- Start a prompt, then press `Ctrl+C` while Claude is working
- Explain: You can always stop Claude mid-action
- Then say: *"Actually, don't add due_date, revert that change"*
→ Point out: Claude can undo its own changes

**Multi-line input:**
- Press `Shift+Enter` to write multi-line prompts (or `\` at end of line)
- Show how to paste a longer spec or error message

**Get participants to try** — Have them launch `claude` and do Exercise 1 (5 min self-paced).

---

## Part 2: Configuration (20 min)

### 2A - CLAUDE.md (10 min) — LIVE CODING

**Open CLAUDE.md and walk through it:**
```bash
cat CLAUDE.md
```

**Talking points:**
- This is the most impactful file for Claude Code productivity
- Claude reads it at the start of every session
- It should contain: build commands, conventions, architecture, common workflows
- It's checked into git — your whole team benefits

**Demo the effect:**
```
"Create a new endpoint to get tasks by tag"
```
→ Point out: Claude follows CLAUDE.md conventions (type hints, /api/v1/ prefix, 404 handling) without being told

**Demo /init:**
```
"What would you generate if I ran /init on this project?"
```
→ Explain: `/init` bootstraps a CLAUDE.md by analyzing your codebase

**Briefly mention scopes:**
- Project: `./CLAUDE.md` (shared via git)
- User: `~/.claude/CLAUDE.md` (personal, all projects)
- Local: `.claude/CLAUDE.local.md` (personal, this project, gitignored)

### 2B - Settings & Permissions (10 min) — LIVE CODING

**Open settings and walk through:**
```bash
cat .claude/settings.json
```

**Demo the allow/deny rules:**
```
"Run the tests"
```
→ Auto-approved (pytest is in allow list) — no prompt!

```
"Delete the src directory"
```
→ Blocked by deny rule — Claude gets feedback and stops

**Explain the mental model:**
- `allow` = auto-approve (no prompt)
- `deny` = block entirely (Claude gets error feedback)
- Everything else = prompt the user

**Show plan mode:**
- Press `Shift+Tab` to toggle plan mode
- Ask: *"How would you refactor database.py to split task and user operations?"*
→ Point out: In plan mode, Claude can only read — it plans but doesn't change anything
- Press `Shift+Tab` again to exit plan mode

**Get participants to try** — Exercises 2 and 3 (5 min self-paced).

---

## Part 3: Automation (20 min)

### 3A - Hooks (10 min) — LIVE CODING

**This is usually the biggest "aha" moment. Take time here.**

**Explain the concept:**
- Hooks = shell commands that run at specific points in Claude's workflow
- Unlike CLAUDE.md (guidance), hooks **enforce** through code
- They receive JSON on stdin, return exit codes

**Demo 1: Auto-formatting (PostToolUse)**
```
"Add a function to utils.py called format_priority that takes a Priority enum and returns an emoji string - use really bad formatting with no spaces"
```
→ After Claude writes the file, ruff auto-formats it
→ Show the before/after — the hook cleaned up the code automatically

**Demo 2: Secret blocker (PreToolUse)**
```
"Add a constant DATABASE_URL = 'postgresql://admin:supersecret123@prod-db:5432/main' to database.py"
```
→ The hook blocks the write!
→ Open `.claude/hooks/check-secrets.sh` and walk through the script
→ Key point: Exit code 2 = block the action, stderr = feedback to Claude

**Demo 3: Show hook JSON input**
```bash
# What hooks receive on stdin:
cat <<'EOF'
{
  "session_id": "abc123",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "src/taskflow/utils.py",
    "old_string": "...",
    "new_string": "..."
  }
}
EOF
```

### 3B - Skills / Slash Commands (10 min) — LIVE CODING

**Explain:**
- Skills = reusable prompt templates invoked with `/command`
- They're markdown files in `.claude/skills/<name>/SKILL.md`
- Can accept `$ARGUMENTS`, restrict tools, inject dynamic context

**Demo the pre-built skills:**
```
/review src/taskflow/routers/tasks.py
```
→ Walk through the structured review output

```
/test-coverage
```
→ Point out: It finds the missing user endpoint tests

```
/add-endpoint "GET /api/v1/tasks/overdue - return tasks past their due date"
```
→ Watch Claude scaffold endpoint, database method, and tests

**Show how to create one:** Open `.claude/skills/review/SKILL.md` and walk through the format.

**Get participants to try** — Exercises 4 and 5 (10 min self-paced).

---

## Part 4: Advanced (15 min)

### 4A - Subagents (7 min) — LIVE CODING

**Explain:**
- Claude can spawn specialized sub-agents with isolated contexts
- Each agent has its own tools, model, and system prompt
- Built-in: Explore (fast search), Plan (read-only design)
- Custom: you define them in `.claude/agents/`

**Demo:**
```
"Investigate how the task assignment flow works - trace from the HTTP endpoint through to the database"
```
→ Watch Claude spawn an Explore agent
→ Point out: It uses a faster model, read-only tools, separate context

**Demo custom agent:**
```
"Use the reviewer agent to review the changes we've made today"
```

**Show the agent definition:**
```bash
cat .claude/agents/reviewer.md
```
→ Point out: model selection, tool restrictions, custom system prompt

### 4B - Context Management (3 min) — TALK + DEMO

**Talking points:**
- Claude has a ~200K token context window
- Long sessions fill up — code reads, tool outputs, conversation all count
- When it fills up, Claude auto-compacts (summarizes and resets)

**Demo:**
```
/compact
```
→ Explain: Manually compacts conversation to free up context
→ Good to do between major tasks

**Mention session resume:**
```bash
# Pick up where you left off
claude --continue        # resume last session
claude --resume          # pick from session list
```

### 4C - Real-World Workflow (5 min) — LIVE CODING

**Tie everything together with one realistic task:**

```
"I need to add a 'search' query parameter to the tasks list endpoint that does case-insensitive substring matching on title and description. Update the database layer, the endpoint, and add tests."
```

Watch Claude:
1. Read existing code (tools: Read, Grep)
2. Plan the approach (may use Plan agent)
3. Edit database.py (hook: auto-formats)
4. Edit tasks.py (hook: auto-formats)
5. Write tests
6. Run tests (Bash)

→ Point out: CLAUDE.md conventions followed, hooks ran automatically, multi-file coordinated change

**If time permits, commit:**
```
"Commit these changes"
```

---

## Wrap-up (5 min)

### Quick Wins to Take Home
1. **Add CLAUDE.md** to your projects today — biggest ROI, 5 minutes of work
2. **Allow common commands** in settings — `pytest`, `npm test`, `git` — reduces prompt fatigue
3. **Create one skill** for your most common workflow (deploy, review, test)

### Resources
- Docs: https://docs.anthropic.com/en/docs/claude-code
- Cheat sheet: See `CHEATSHEET.md` in this repo
- Report issues: https://github.com/anthropics/claude-code/issues

### Common Questions

**Q: Does Claude send my code to Anthropic?**
A: Claude Code sends the parts of your code it reads to the Anthropic API. Review the privacy policy and data retention settings. Enterprise plans offer zero data retention.

**Q: Can I use this with other editors?**
A: Yes — VS Code extension, JetBrains plugin, or plain terminal. All share the same underlying engine.

**Q: What about cost?**
A: Claude Code uses your Anthropic API key or Claude subscription. Usage depends on how much code Claude reads and generates. The `/compact` command and subagents help manage context usage.

**Q: Can I use it in CI/CD?**
A: Yes — `claude -p "prompt" --allowedTools '["Bash","Edit"]'` runs non-interactively. Use `--output-format json` for structured output.

---

## Timing Summary

| Section | Duration | Style |
|---------|----------|-------|
| 1A: What is Claude Code | 5 min | Talk + demo |
| 1B: Basic interactions | 10 min | Live coding |
| 1C: Navigation & recovery | 10 min | Live coding + self-paced |
| 2A: CLAUDE.md | 10 min | Live coding |
| 2B: Settings & permissions | 10 min | Live coding + self-paced |
| 3A: Hooks | 10 min | Live coding |
| 3B: Skills | 10 min | Live coding + self-paced |
| 4A: Subagents | 7 min | Live coding |
| 4B: Context management | 3 min | Talk + demo |
| 4C: Real-world workflow | 5 min | Live coding |
| Wrap-up | 5 min | Talk |
| **Total** | **~85 min** | |
