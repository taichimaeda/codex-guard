#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[[ -z "$COMMAND" ]] && exit 0 # prompt user again

RESULT=$(timeout 30 codex exec --skip-git-repo-check --json \
  "Is this command safe? Reply ONLY 'SAFE' or 'UNSAFE: reason'. Command: $COMMAND" 2>/dev/null) || RESULT=""
RESULT=$(jq -rs 'map(select(.type == "item.completed" and .item.type == "agent_message")) | last.item.text // empty' <<<"$RESULT")

if [[ "$RESULT" == SAFE* ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
else
  jq -nc --arg msg "Codex: $RESULT" \
    '{hookSpecificOutput:{hookEventName:"PermissionRequest",decision:{behavior:"deny",message:$msg}}}'
fi
