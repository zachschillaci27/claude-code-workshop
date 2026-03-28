# Exercise 8: Real-World Workflow - Putting It All Together

## Goal
Combine everything you've learned into a realistic development workflow.

## Scenario
You've been asked to add a **task search endpoint** with full-text search by title and description.

## Workflow

### Step 1: Plan with Claude
```
"I need to add a search endpoint for tasks. Plan the implementation - what files need to change and what's the approach?"
```
Claude uses the **Plan** agent to analyze the codebase and propose a strategy.

### Step 2: Scaffold with a Skill
```
/add-endpoint "GET /api/v1/tasks/search - search tasks by title and description using a query parameter 'q'"
```

### Step 3: Review the Changes
```
/review src/taskflow/routers/tasks.py
```

### Step 4: Check Test Coverage
```
/test-coverage src/taskflow/routers/tasks.py
```

### Step 5: Run Tests
```
"Run the tests"
```
If you completed Exercise 4.3, the PostToolUse hook auto-runs tests after each edit!

### Step 6: Commit
```
"Commit these changes with a descriptive message"
```

## Bonus Challenges

### Challenge A: Bug Fix Workflow
There's no validation that task assignees actually exist when creating a task.
```
"When creating a task, validate that the assignee (if provided) exists in the user database. Return 404 if not found."
```

### Challenge B: Feature with Edge Cases
```
"Add a PATCH /api/v1/tasks/{task_id}/tags endpoint that supports adding and removing individual tags without replacing the entire list. Use query params: action=add&tag=urgent or action=remove&tag=urgent"
```

### Challenge C: Refactoring
```
"The database.py file is getting large. Refactor it to split task operations and user operations into separate files while maintaining the same public API."
```

### Challenge D: Multi-File Change with Agents
```
"Add a 'due_date' field to tasks. This needs changes to models, database, routers, and tests. Use agents to parallelize the work."
```

## Key Takeaways
- Claude Code fits naturally into development workflows
- Skills automate repetitive patterns (scaffold, review, test)
- Hooks enforce quality (formatting, linting, testing)
- Agents parallelize independent work
- CLAUDE.md ensures consistency across all interactions
