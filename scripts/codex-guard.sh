#!/usr/bin/env bash
set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[[ -z "$COMMAND" ]] && echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}' && exit 0

# Ask Codex with JSON output, extract final agent message
RESULT=$(timeout 30 codex exec --skip-git-repo-check --json \
  "Is this command safe? Reply ONLY 'SAFE' or 'UNSAFE: reason'. Command: $COMMAND" \
  2>/dev/null | jq -rs 'map(select(.type == "item.completed" and .item.type == "agent_message")) | last.item.text // empty') || RESULT=""

if [[ "$RESULT" == SAFE* ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
else
  # Build JSON output properly using jq
  jq -nc --arg msg "Codex: $RESULT" '{
    hookSpecificOutput: {
      hookEventName: "PermissionRequest",
      decision: {
        behavior: "deny",
        message: $msg
      }
    }
  }'
fi
