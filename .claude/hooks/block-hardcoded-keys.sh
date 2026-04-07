#!/bin/bash
# Hook: PreToolUse - Block writes that contain hardcoded secrets
#
# This hook reads the tool input from stdin and checks if the file
# content being written contains patterns that look like secrets.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

# Skip non-Python files
if [[ "$FILE_PATH" != *.py ]] && [[ "$FILE_PATH" != *.json ]] && [[ "$FILE_PATH" != *.yaml ]]; then
    exit 0
fi

# Check for common secret patterns
PATTERNS=(
    'password\s*=\s*"[^"]{8,}"'
    'api_key\s*=\s*"[^"]{8,}"'
    'secret\s*=\s*"[^"]{8,}"'
    'token\s*=\s*"[A-Za-z0-9]{20,}"'
    'AWS_SECRET_ACCESS_KEY'
    'PRIVATE_KEY'
)

for pattern in "${PATTERNS[@]}"; do
    if echo "$NEW_CONTENT" | grep -iEq "$pattern"; then
        echo "Blocked: Content appears to contain a hardcoded secret matching pattern '$pattern'. Use environment variables instead." >&2
        exit 2
    fi
done

exit 0
