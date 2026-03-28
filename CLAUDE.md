# TaskFlow API

A Python FastAPI task management API used for the Claude Code workshop.

## Build & Run

- Install: `pip install -e ".[dev]"`
- Run server: `uvicorn taskflow.main:app --reload`
- Run tests: `pytest`
- Run single test: `pytest tests/test_tasks.py::test_create_task -v`
- Lint: `ruff check src/ tests/`
- Format: `ruff format src/ tests/`

## Architecture

- `src/taskflow/main.py` - FastAPI app entry point
- `src/taskflow/models.py` - Pydantic request/response models
- `src/taskflow/database.py` - In-memory database with seed data
- `src/taskflow/routers/tasks.py` - Task CRUD endpoints
- `src/taskflow/routers/users.py` - User endpoints
- `src/taskflow/utils.py` - Helper functions
- `tests/` - Pytest test suite

## Code Conventions

- Use type hints on all function signatures
- Prefer `str | None` over `Optional[str]`
- Keep endpoint handlers thin - business logic goes in database layer
- Tests use the `client` fixture from `conftest.py`
- Sort imports with `ruff` (isort-compatible)

## API Design

- All endpoints are under `/api/v1/`
- Use proper HTTP status codes (201 for create, 204 for delete)
- Return 404 with detail message for missing resources
- Use query parameters for filtering, not request body
